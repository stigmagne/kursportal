'use client';

import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { createPortalSession } from '@/app/actions/stripe';
import { useTranslations } from 'next-intl';
import { Link } from '@/i18n/routing';

interface Subscription {
    id: string;
    status: string;
    price: {
        unit_amount: number | null;
        currency: string | null;
        interval: string | null;
        product: {
            name: string;
        } | null;
    } | null;
    current_period_end: string;
}

export default function SubscriptionStatus({ subscription }: { subscription: Subscription | null }) {
    const t = useTranslations('Dashboard');

    if (!subscription) {
        return (
            <Card>
                <CardHeader>
                    <CardTitle>{t('member_status')}</CardTitle>
                    <CardDescription>{t('no_subscription')}</CardDescription>
                </CardHeader>
                <CardContent>
                    <Button asChild>
                        <Link href="/pricing">{t('view_plans')}</Link>
                    </Button>
                </CardContent>
            </Card>
        );
    }

    const price = subscription.price;
    const productName = price?.product?.name || t('subscription');
    const amount = price?.unit_amount ? price.unit_amount / 100 : 0;
    const currency = price?.currency?.toUpperCase() || '';

    return (
        <Card>
            <CardHeader>
                <CardTitle>{productName}</CardTitle>
                <CardDescription>
                    {t('status')}: <span className="capitalize font-medium text-foreground">{subscription.status}</span>
                </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
                <div className="text-2xl font-bold">
                    {currency} {amount}/{price?.interval}
                </div>
                <div className="text-sm text-muted-foreground">
                    {t('renews')}: {new Date(subscription.current_period_end).toLocaleDateString()}
                </div>
                <form action={createPortalSession}>
                    <Button variant="outline" type="submit">
                        {t('manage_subscription')}
                    </Button>
                </form>
            </CardContent>
        </Card>
    );
}
