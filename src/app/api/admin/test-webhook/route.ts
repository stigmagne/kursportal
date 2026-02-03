import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@/utils/supabase/server';

const ALLOWED_WEBHOOK_HOSTS = [
    'hooks.slack.com',
    'discord.com',
    'discordapp.com',
    'outlook.office.com',
    'outlook.office365.com',
];

function isAllowedWebhookUrl(urlString: string): boolean {
    try {
        const url = new URL(urlString);
        if (url.protocol !== 'https:') return false;
        return ALLOWED_WEBHOOK_HOSTS.some(host => url.hostname.endsWith(host));
    } catch {
        return false;
    }
}

export async function POST(request: NextRequest) {
    const supabase = await createClient();

    // Check if user is admin
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
        return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { data: profile } = await supabase
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .single();

    if (profile?.role !== 'admin') {
        return NextResponse.json({ error: 'Forbidden' }, { status: 403 });
    }

    try {
        const { channel, webhookUrl } = await request.json();

        if (!channel || !webhookUrl) {
            return NextResponse.json({ error: 'Missing channel or webhookUrl' }, { status: 400 });
        }

        if (!isAllowedWebhookUrl(webhookUrl)) {
            return NextResponse.json(
                { error: 'Invalid webhook URL. Only Slack, Discord and Teams webhook URLs are allowed.' },
                { status: 400 }
            );
        }

        let body: object;
        const testMessage = '🧪 Test fra EHSO Kursportal - Webhook fungerer!';

        switch (channel) {
            case 'slack':
                body = {
                    blocks: [
                        {
                            type: 'section',
                            text: { type: 'mrkdwn', text: testMessage }
                        }
                    ]
                };
                break;

            case 'discord':
                body = {
                    embeds: [{
                        title: 'EHSO Kursportal',
                        description: testMessage,
                        color: 0x22c55e
                    }]
                };
                break;

            case 'teams':
                body = {
                    type: 'message',
                    attachments: [{
                        contentType: 'application/vnd.microsoft.card.adaptive',
                        content: {
                            $schema: 'http://adaptivecards.io/schemas/adaptive-card.json',
                            type: 'AdaptiveCard',
                            version: '1.4',
                            body: [{
                                type: 'TextBlock',
                                text: testMessage,
                                wrap: true
                            }]
                        }
                    }]
                };
                break;

            default:
                return NextResponse.json({ error: 'Invalid channel' }, { status: 400 });
        }

        const response = await fetch(webhookUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(body)
        });

        if (response.ok) {
            return NextResponse.json({ success: true });
        } else {
            const errorText = await response.text();
            return NextResponse.json({ success: false, error: errorText }, { status: 400 });
        }
    } catch {
        return NextResponse.json({ success: false, error: 'Failed to send test webhook' }, { status: 500 });
    }
}
