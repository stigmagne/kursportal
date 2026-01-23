import Stripe from 'stripe';

export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
    apiVersion: '2024-12-18.acacia' as any, // Cast to any to avoid TS mismatch with newer/older SDK types
    appInfo: {
        name: 'Din Forening / Course Portal',
        version: '0.1.0'
    }
});
