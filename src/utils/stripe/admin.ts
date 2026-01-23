import { createClient } from '@supabase/supabase-js';
import Stripe from 'stripe';
import { stripe } from './server';

// Note: This must be used in a secure server-side context (e.g. Webhook handler)
// We use the SERVICE_ROLE_KEY to bypass RLS when writing webhooks data to the DB.
const supabaseAdmin = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL || '',
    process.env.SUPABASE_SERVICE_ROLE_KEY || ''
);

const toDateTime = (secs: number) => {
    var t = new Date('1970-01-01T00:30:00Z'); // Unix epoch start.
    t.setSeconds(secs);
    return t;
};

export const upsertProductRecord = async (product: Stripe.Product) => {
    const productData = {
        id: product.id,
        active: product.active,
        name: product.name,
        description: product.description ?? undefined,
        image: product.images?.[0] ?? null,
        metadata: product.metadata
    };

    const { error } = await supabaseAdmin.from('products').upsert([productData]);
    if (error) throw error;
    console.log(`Product inserted/updated: ${product.id}`);
};

export const upsertPriceRecord = async (price: Stripe.Price) => {
    const priceData = {
        id: price.id,
        product_id: typeof price.product === 'string' ? price.product : '',
        active: price.active,
        currency: price.currency,
        description: price.nickname ?? undefined,
        type: price.type,
        unit_amount: price.unit_amount ?? undefined,
        interval: price.recurring?.interval,
        interval_count: price.recurring?.interval_count,
        trial_period_days: price.recurring?.trial_period_days,
        metadata: price.metadata
    };

    const { error } = await supabaseAdmin.from('prices').upsert([priceData]);
    if (error) throw error;
    console.log(`Price inserted/updated: ${price.id}`);
};

export const createOrRetrieveCustomer = async ({
    email,
    uuid
}: {
    email: string;
    uuid: string;
}) => {
    const { data, error } = await supabaseAdmin
        .from('customers')
        .select('stripe_customer_id')
        .eq('id', uuid)
        .single();

    if (error || !data?.stripe_customer_id) {
        // No customer record found, let's create one in Stripe
        const customer = await stripe.customers.create({
            email: email,
            metadata: {
                supabaseUUID: uuid
            }
        });

        if (!customer) throw new Error('Stripe customer creation failed.');

        const { error: supabaseError } = await supabaseAdmin
            .from('customers')
            .insert([{ id: uuid, stripe_customer_id: customer.id }]);

        if (supabaseError) throw supabaseError;
        console.log(`New customer created and inserted for ${uuid}.`);
        return customer.id;
    }
    return data.stripe_customer_id;
};

export const copyBillingDetailsToCustomer = async (
    uuid: string,
    payment_method: Stripe.PaymentMethod
) => {
    //Todo: copy details to customer
    const customer = payment_method.customer as string;
    const { name, phone, address } = payment_method.billing_details;
    if (!name || !phone || !address) return;
    //@ts-ignore
    await stripe.customers.update(customer, { name, phone, address });
    const { error } = await supabaseAdmin
        .from('users')
        .update({
            billing_address: { ...address },
            payment_method: { ...payment_method[payment_method.type] }
        })
        .eq('id', uuid);
    if (error) throw error;
};

export const manageSubscriptionStatusChange = async (
    subscriptionId: string,
    customerId: string,
    createAction = false
) => {
    // Get customer's UUID from mapping table.
    const { data: customerData, error: noCustomerError } = await supabaseAdmin
        .from('customers')
        .select('id')
        .eq('stripe_customer_id', customerId)
        .single();

    if (noCustomerError) throw noCustomerError;

    const { id: uuid } = customerData!;

    const subscriptionResponse = await stripe.subscriptions.retrieve(subscriptionId, {
        expand: ['default_payment_method']
    });
    const subscription = subscriptionResponse as unknown as Stripe.Subscription;

    // Upsert the latest status of the subscription object.
    const subscriptionData = {
        id: subscription.id,
        user_id: uuid,
        metadata: subscription.metadata,
        status: subscription.status,
        price_id: subscription.items.data[0].price.id,
        // @ts-ignore
        quantity: subscription.quantity,
        cancel_at_period_end: subscription.cancel_at_period_end,
        cancel_at: subscription.cancel_at ? toDateTime(subscription.cancel_at) : null,
        canceled_at: subscription.canceled_at
            ? toDateTime(subscription.canceled_at)
            : null,
        // @ts-ignore
        current_period_start: toDateTime(subscription.current_period_start),
        // @ts-ignore
        current_period_end: toDateTime(subscription.current_period_end),
        created: toDateTime(subscription.created),
        ended_at: subscription.ended_at ? toDateTime(subscription.ended_at) : null,
        trial_start: subscription.trial_start
            ? toDateTime(subscription.trial_start)
            : null,
        trial_end: subscription.trial_end
            ? toDateTime(subscription.trial_end)
            : null
    };

    const { error } = await supabaseAdmin
        .from('subscriptions')
        .upsert([subscriptionData]);
    if (error) throw error;
    console.log(
        `Inserted/updated subscription [${subscription.id}] for user [${uuid}]`
    );

    // For a new subscription copy the billing details to the customer object.
    // NOTE: This is a cost optimization to avoid billing details updates on every webhook.
    if (createAction && subscription.default_payment_method && uuid) {
        //@ts-ignore
        await copyBillingDetailsToCustomer(
            uuid,
            subscription.default_payment_method as Stripe.PaymentMethod
        );
    }
};
