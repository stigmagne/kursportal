import Stripe from 'stripe';

let stripeInstance: Stripe | null = null;

export function getStripe(): Stripe {
    if (!stripeInstance) {
        const key = process.env.STRIPE_SECRET_KEY;
        if (!key) {
            throw new Error('STRIPE_SECRET_KEY is not set');
        }
        stripeInstance = new Stripe(key, {
            apiVersion: '2024-12-18.acacia' as any,
            appInfo: {
                name: 'Din Forening / Course Portal',
                version: '0.1.0'
            }
        });
    }
    return stripeInstance;
}

// For backwards compatibility - lazy initialization
export const stripe = new Proxy({} as Stripe, {
    get(_, prop) {
        return (getStripe() as any)[prop];
    }
});
