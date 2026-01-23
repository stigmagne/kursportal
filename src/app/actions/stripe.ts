'use server';

import { createClient } from '@/utils/supabase/server';
import { stripe } from '@/utils/stripe/server';
import { createOrRetrieveCustomer } from '@/utils/stripe/admin';
import { redirect } from 'next/navigation';
// import { getURL } from '@/lib/utils'; // Not needed as we use local helper

const getCallbackUrl = () => {
    let url =
        process.env.NEXT_PUBLIC_SITE_URL ?? // Set this to your site URL in production env.
        process.env.NEXT_PUBLIC_VERCEL_URL ?? // Automatically set by Vercel.
        'http://localhost:3000/';
    // Make sure to include `https://` when not localhost.
    url = url.includes('http') ? url : `https://${url}`;
    // Make sure to include a trailing `/`.
    url = url.charAt(url.length - 1) === '/' ? url : `${url}/`;
    return url;
};

export async function createCheckoutSession(priceId: string) {
    const supabase = await createClient();
    const {
        data: { user }
    } = await supabase.auth.getUser();

    if (!user) {
        throw new Error('User not authenticated.');
    }

    try {
        const customer = await createOrRetrieveCustomer({
            uuid: user.id || '',
            email: user.email || ''
        });

        if (!customer) throw new Error('Could not get customer');

        const session = await stripe.checkout.sessions.create({
            billing_address_collection: 'required',
            customer,
            line_items: [
                {
                    price: priceId,
                    quantity: 1
                }
            ],
            mode: 'subscription',
            // Note: If you support one-time payments, you need to check price.type first. 
            // For now assuming subscription based on task.
            allow_promotion_codes: true,
            success_url: `${getCallbackUrl()}dashboard`,
            cancel_url: `${getCallbackUrl()}pricing`
        });

        if (session.url) {
            redirect(session.url);
        }
    } catch (err: any) {
        console.error(err);
        throw new Error('Could not create checkout session: ' + err.message);
    }
}

export async function createPortalSession() {
    const supabase = await createClient();
    const {
        data: { user }
    } = await supabase.auth.getUser();

    if (!user) {
        throw new Error('User not authenticated.');
    }

    try {
        const customer = await createOrRetrieveCustomer({
            uuid: user.id || '',
            email: user.email || ''
        });

        if (!customer) throw new Error('Could not get customer');

        const session = await stripe.billingPortal.sessions.create({
            customer,
            return_url: `${getCallbackUrl()}dashboard`
        });

        if (session.url) {
            redirect(session.url);
        }
    } catch (err: any) {
        console.error(err);
        throw new Error('Could not create portal session');
    }
}
