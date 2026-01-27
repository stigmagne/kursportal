import { createClient } from '@/utils/supabase/server';

// Event types for notifications
export type NotificationEvent =
    | 'user_signup'
    | 'course_complete'
    | 'quiz_pass'
    | 'comment_posted';

interface NotificationData {
    userName?: string;
    userEmail?: string;
    courseName?: string;
    quizName?: string;
    score?: number;
    lessonName?: string;
    commentPreview?: string;
}

interface NotificationSettings {
    slack_webhook_url: string | null;
    discord_webhook_url: string | null;
    teams_webhook_url: string | null;
    notify_on_signup: boolean;
    notify_on_course_complete: boolean;
    notify_on_quiz_pass: boolean;
    notify_on_comment: boolean;
}

// Get notification settings from database
async function getNotificationSettings(): Promise<NotificationSettings | null> {
    const supabase = await createClient();
    const { data, error } = await supabase
        .from('notification_settings')
        .select('*')
        .limit(1)
        .single();

    if (error) {
        console.error('Failed to fetch notification settings:', error);
        return null;
    }
    return data;
}

// Log notification attempt
async function logNotification(
    eventType: NotificationEvent,
    channel: 'slack' | 'discord' | 'teams',
    payload: object,
    success: boolean,
    errorMessage?: string
) {
    try {
        const supabase = await createClient();
        await supabase.from('notification_log').insert({
            event_type: eventType,
            channel,
            payload,
            success,
            error_message: errorMessage
        });
    } catch (e) {
        console.error('Failed to log notification:', e);
    }
}

// Format message for different events
function formatMessage(event: NotificationEvent, data: NotificationData): string {
    switch (event) {
        case 'user_signup':
            return `🎉 Ny bruker registrert: ${data.userName || 'Ukjent'} (${data.userEmail || ''})`;
        case 'course_complete':
            return `🎓 ${data.userName || 'En bruker'} har fullført kurset "${data.courseName || 'Ukjent kurs'}"`;
        case 'quiz_pass':
            return `✅ ${data.userName || 'En bruker'} bestod quizen "${data.quizName || 'Ukjent quiz'}" med ${data.score || 0}%`;
        case 'comment_posted':
            return `💬 Ny kommentar fra ${data.userName || 'En bruker'} på "${data.lessonName || 'en leksjon'}"`;
        default:
            return 'Ny hendelse i kursportalen';
    }
}

// Send to Slack
async function sendSlackNotification(
    webhookUrl: string,
    event: NotificationEvent,
    data: NotificationData
): Promise<boolean> {
    const message = formatMessage(event, data);

    try {
        const response = await fetch(webhookUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                blocks: [
                    {
                        type: 'section',
                        text: {
                            type: 'mrkdwn',
                            text: message
                        }
                    },
                    {
                        type: 'context',
                        elements: [
                            {
                                type: 'mrkdwn',
                                text: `EHSO Kursportal • ${new Date().toLocaleString('no-NO')}`
                            }
                        ]
                    }
                ]
            })
        });

        const success = response.ok;
        await logNotification(event, 'slack', data, success, success ? undefined : await response.text());
        return success;
    } catch (error) {
        await logNotification(event, 'slack', data, false, String(error));
        return false;
    }
}

// Send to Discord
async function sendDiscordNotification(
    webhookUrl: string,
    event: NotificationEvent,
    data: NotificationData
): Promise<boolean> {
    const message = formatMessage(event, data);

    // Color based on event type
    const colors: Record<NotificationEvent, number> = {
        user_signup: 0x22c55e,    // green
        course_complete: 0x6366f1, // indigo
        quiz_pass: 0xeab308,      // yellow
        comment_posted: 0x3b82f6  // blue
    };

    try {
        const response = await fetch(webhookUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                embeds: [{
                    title: 'EHSO Kursportal',
                    description: message,
                    color: colors[event],
                    timestamp: new Date().toISOString(),
                    footer: {
                        text: 'Kursportal Notifikasjon'
                    }
                }]
            })
        });

        const success = response.ok;
        await logNotification(event, 'discord', data, success, success ? undefined : await response.text());
        return success;
    } catch (error) {
        await logNotification(event, 'discord', data, false, String(error));
        return false;
    }
}

// Send to Microsoft Teams
async function sendTeamsNotification(
    webhookUrl: string,
    event: NotificationEvent,
    data: NotificationData
): Promise<boolean> {
    const message = formatMessage(event, data);

    try {
        const response = await fetch(webhookUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                type: 'message',
                attachments: [{
                    contentType: 'application/vnd.microsoft.card.adaptive',
                    contentUrl: null,
                    content: {
                        $schema: 'http://adaptivecards.io/schemas/adaptive-card.json',
                        type: 'AdaptiveCard',
                        version: '1.4',
                        body: [
                            {
                                type: 'TextBlock',
                                text: 'EHSO Kursportal',
                                weight: 'bolder',
                                size: 'medium'
                            },
                            {
                                type: 'TextBlock',
                                text: message,
                                wrap: true
                            },
                            {
                                type: 'TextBlock',
                                text: new Date().toLocaleString('no-NO'),
                                size: 'small',
                                isSubtle: true
                            }
                        ]
                    }
                }]
            })
        });

        const success = response.ok;
        await logNotification(event, 'teams', data, success, success ? undefined : await response.text());
        return success;
    } catch (error) {
        await logNotification(event, 'teams', data, false, String(error));
        return false;
    }
}

// Check if event should trigger notification
function shouldNotify(settings: NotificationSettings, event: NotificationEvent): boolean {
    switch (event) {
        case 'user_signup': return settings.notify_on_signup;
        case 'course_complete': return settings.notify_on_course_complete;
        case 'quiz_pass': return settings.notify_on_quiz_pass;
        case 'comment_posted': return settings.notify_on_comment;
        default: return false;
    }
}

// Main function to notify all configured channels
export async function notifyAdmins(
    event: NotificationEvent,
    data: NotificationData
): Promise<void> {
    const settings = await getNotificationSettings();

    if (!settings || !shouldNotify(settings, event)) {
        return;
    }

    const promises: Promise<boolean>[] = [];

    if (settings.slack_webhook_url) {
        promises.push(sendSlackNotification(settings.slack_webhook_url, event, data));
    }

    if (settings.discord_webhook_url) {
        promises.push(sendDiscordNotification(settings.discord_webhook_url, event, data));
    }

    if (settings.teams_webhook_url) {
        promises.push(sendTeamsNotification(settings.teams_webhook_url, event, data));
    }

    await Promise.allSettled(promises);
}

// Test webhook function for admin UI
export async function testWebhook(
    channel: 'slack' | 'discord' | 'teams',
    webhookUrl: string
): Promise<{ success: boolean; error?: string }> {
    const testData: NotificationData = {
        userName: 'Test Bruker',
        userEmail: 'test@example.com'
    };

    try {
        let success = false;

        switch (channel) {
            case 'slack':
                success = await sendSlackNotification(webhookUrl, 'user_signup', testData);
                break;
            case 'discord':
                success = await sendDiscordNotification(webhookUrl, 'user_signup', testData);
                break;
            case 'teams':
                success = await sendTeamsNotification(webhookUrl, 'user_signup', testData);
                break;
        }

        return { success };
    } catch (error) {
        return { success: false, error: String(error) };
    }
}
