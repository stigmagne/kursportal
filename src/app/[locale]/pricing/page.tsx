import { createClient } from '@/utils/supabase/server';
import { getTranslations } from 'next-intl/server';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card';
import { createCheckoutSession } from '@/app/actions/stripe';

interface Product {
    id: string;
    name: string;
    description: string | null;
    image: string | null;
    metadata: any;
    prices: Price[];
}

interface Price {
    id: string;
    unit_amount: number | null;
    currency: string | null;
    interval: string | null;
    description: string | null;
}

export default async function PricingPage({ params }: { params: { locale: string } }) {
    const { locale } = await params;
    const t = await getTranslations('Pricing'); // Ensure you add these keys later
    const supabase = await createClient();

    const { data: products } = await supabase
        .from('products')
        .select('*, prices(*)')
        .eq('active', true)
        .eq('prices.active', true)
        .order('metadata->index')
        .order('unit_amount', { foreignTable: 'prices' });

    return (
        <div className="container py-10 mx-auto">
            <div className="text-center mb-10">
                <h1 className="text-4xl font-bold tracking-tight mb-4 text-gray-900">{t('title') || 'Pricing'}</h1>
                <p className="text-lg text-gray-600">{t('subtitle') || 'Choose the plan that fits you best'}</p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                {products?.map((product: any) => {
                    const price = product.prices?.[0]; // Assuming 1 price per product for simplicity
                    if (!price) return null;

                    return (
                        <Card key={product.id} className="flex flex-col">
                            <CardHeader>
                                <CardTitle>{product.name}</CardTitle>
                                <CardDescription>{product.description}</CardDescription>
                            </CardHeader>
                            <CardContent className="flex-1">
                                <div className="text-3xl font-bold">
                                    {new Intl.NumberFormat(locale, {
                                        style: 'currency',
                                        currency: price.currency
                                    }).format((price.unit_amount || 0) / 100)}
                                    <span className="text-sm font-normal text-gray-500">/{price.interval}</span>
                                </div>
                            </CardContent>
                            <CardFooter>
                                <form action={createCheckoutSession.bind(null, price.id)} className="w-full">
                                    <Button className="w-full" type="submit">
                                        {t('subscribe') || 'Subscribe'}
                                    </Button>
                                </form>
                            </CardFooter>
                        </Card>
                    );
                })}
            </div>

            {(!products || products.length === 0) && (
                <div className="text-center py-10">
                    <p>{t('no_products')}</p>
                </div>
            )}
        </div>
    );
}
