'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import { Save, TestTube, Slack, MessageCircle } from 'lucide-react';
import { showToast } from '@/lib/toast';

interface NotificationSettings {
    id: string;
    slack_webhook_url: string | null;
    discord_webhook_url: string | null;
    teams_webhook_url: string | null;
    notify_on_signup: boolean;
    notify_on_course_complete: boolean;
    notify_on_quiz_pass: boolean;
    notify_on_comment: boolean;
}

export default function IntegrationSettings() {
    const [settings, setSettings] = useState<NotificationSettings | null>(null);
    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);
    const [testing, setTesting] = useState<string | null>(null);

    useEffect(() => {
        fetchSettings();
    }, []);

    async function fetchSettings() {
        const supabase = createClient();
        const { data, error } = await supabase
            .from('notification_settings')
            .select('*')
            .limit(1)
            .single();

        if (error) {
            console.error('Failed to fetch settings:', error);
            // Create default settings if none exist
            const { data: newData } = await supabase
                .from('notification_settings')
                .insert({})
                .select()
                .single();
            setSettings(newData);
        } else {
            setSettings(data);
        }
        setLoading(false);
    }

    async function saveSettings() {
        if (!settings) return;

        setSaving(true);
        const supabase = createClient();

        const { error } = await supabase
            .from('notification_settings')
            .update({
                slack_webhook_url: settings.slack_webhook_url || null,
                discord_webhook_url: settings.discord_webhook_url || null,
                teams_webhook_url: settings.teams_webhook_url || null,
                notify_on_signup: settings.notify_on_signup,
                notify_on_course_complete: settings.notify_on_course_complete,
                notify_on_quiz_pass: settings.notify_on_quiz_pass,
                notify_on_comment: settings.notify_on_comment,
                updated_at: new Date().toISOString()
            })
            .eq('id', settings.id);

        setSaving(false);

        if (error) {
            showToast.error('Kunne ikke lagre innstillinger');
        } else {
            showToast.success('Innstillinger lagret!');
        }
    }

    async function testWebhook(channel: 'slack' | 'discord' | 'teams') {
        if (!settings) return;

        const url = channel === 'slack' ? settings.slack_webhook_url :
            channel === 'discord' ? settings.discord_webhook_url :
                settings.teams_webhook_url;

        if (!url) {
            showToast.error('Ingen webhook URL konfigurert');
            return;
        }

        setTesting(channel);

        try {
            const response = await fetch('/api/admin/test-webhook', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ channel, webhookUrl: url })
            });

            const result = await response.json();

            if (result.success) {
                showToast.success(`${channel.charAt(0).toUpperCase() + channel.slice(1)} test sendt!`);
            } else {
                showToast.error(`Test feilet: ${result.error || 'Ukjent feil'}`);
            }
        } catch {
            showToast.error('Kunne ikke sende test');
        }

        setTesting(null);
    }

    if (loading) {
        return (
            <div className="animate-pulse space-y-4">
                <div className="h-8 bg-muted rounded w-1/3"></div>
                <div className="h-32 bg-muted rounded"></div>
            </div>
        );
    }

    if (!settings) return null;

    return (
        <div className="space-y-6">
            <div>
                <h2 className="text-xl font-semibold flex items-center gap-2">
                    <MessageCircle className="w-5 h-5" />
                    Integrasjoner
                </h2>
                <p className="text-sm text-muted-foreground mt-1">
                    Koble til Slack, Discord eller Teams for å motta varsler
                </p>
            </div>

            {/* Webhook URLs */}
            <div className="space-y-4">
                {/* Slack */}
                <div className="space-y-2">
                    <label className="text-sm font-medium flex items-center gap-2">
                        <Slack className="w-4 h-4" />
                        Slack Webhook URL
                    </label>
                    <div className="flex gap-2">
                        <input
                            type="url"
                            value={settings.slack_webhook_url || ''}
                            onChange={(e) => setSettings({ ...settings, slack_webhook_url: e.target.value })}
                            placeholder="https://hooks.slack.com/services/..."
                            className="flex-1 px-3 py-2 rounded-lg border bg-background text-sm"
                        />
                        <button
                            onClick={() => testWebhook('slack')}
                            disabled={!settings.slack_webhook_url || testing === 'slack'}
                            className="px-3 py-2 rounded-lg bg-muted hover:bg-muted/80 disabled:opacity-50 transition-colors"
                        >
                            <TestTube className={`w-4 h-4 ${testing === 'slack' ? 'animate-pulse' : ''}`} />
                        </button>
                    </div>
                </div>

                {/* Discord */}
                <div className="space-y-2">
                    <label className="text-sm font-medium flex items-center gap-2">
                        <svg className="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M20.317 4.37a19.791 19.791 0 0 0-4.885-1.515.074.074 0 0 0-.079.037c-.21.375-.444.864-.608 1.25a18.27 18.27 0 0 0-5.487 0 12.64 12.64 0 0 0-.617-1.25.077.077 0 0 0-.079-.037A19.736 19.736 0 0 0 3.677 4.37a.07.07 0 0 0-.032.027C.533 9.046-.32 13.58.099 18.057a.082.082 0 0 0 .031.057 19.9 19.9 0 0 0 5.993 3.03.078.078 0 0 0 .084-.028 14.09 14.09 0 0 0 1.226-1.994.076.076 0 0 0-.041-.106 13.107 13.107 0 0 1-1.872-.892.077.077 0 0 1-.008-.128 10.2 10.2 0 0 0 .372-.292.074.074 0 0 1 .077-.01c3.928 1.793 8.18 1.793 12.062 0a.074.074 0 0 1 .078.01c.12.098.246.198.373.292a.077.077 0 0 1-.006.127 12.299 12.299 0 0 1-1.873.892.077.077 0 0 0-.041.107c.36.698.772 1.362 1.225 1.993a.076.076 0 0 0 .084.028 19.839 19.839 0 0 0 6.002-3.03.077.077 0 0 0 .032-.054c.5-5.177-.838-9.674-3.549-13.66a.061.061 0 0 0-.031-.03z" />
                        </svg>
                        Discord Webhook URL
                    </label>
                    <div className="flex gap-2">
                        <input
                            type="url"
                            value={settings.discord_webhook_url || ''}
                            onChange={(e) => setSettings({ ...settings, discord_webhook_url: e.target.value })}
                            placeholder="https://discord.com/api/webhooks/..."
                            className="flex-1 px-3 py-2 rounded-lg border bg-background text-sm"
                        />
                        <button
                            onClick={() => testWebhook('discord')}
                            disabled={!settings.discord_webhook_url || testing === 'discord'}
                            className="px-3 py-2 rounded-lg bg-muted hover:bg-muted/80 disabled:opacity-50 transition-colors"
                        >
                            <TestTube className={`w-4 h-4 ${testing === 'discord' ? 'animate-pulse' : ''}`} />
                        </button>
                    </div>
                </div>

                {/* Teams */}
                <div className="space-y-2">
                    <label className="text-sm font-medium flex items-center gap-2">
                        <svg className="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M19.19 8.77c-.94 0-1.8.3-2.52.81V9.5c0-.83-.67-1.5-1.5-1.5h-4.83c.42-.45.66-1.04.66-1.67 0-1.38-1.12-2.5-2.5-2.5S6 4.95 6 6.33c0 .63.24 1.22.66 1.67H5.5c-.83 0-1.5.67-1.5 1.5v4.33c-.51-.72-1.17-1.02-2.11-1.02-1.38 0-2.5 1.12-2.5 2.5s1.12 2.5 2.5 2.5c.94 0 1.6-.3 2.11-1.02V20.5c0 .83.67 1.5 1.5 1.5h13c.83 0 1.5-.67 1.5-1.5V11.27c.72.51 1.58.81 2.52.81 1.38 0 2.5-1.12 2.5-2.5s-1.12-2.5-2.5-2.5z" />
                        </svg>
                        Microsoft Teams Webhook URL
                    </label>
                    <div className="flex gap-2">
                        <input
                            type="url"
                            value={settings.teams_webhook_url || ''}
                            onChange={(e) => setSettings({ ...settings, teams_webhook_url: e.target.value })}
                            placeholder="https://outlook.office.com/webhook/..."
                            className="flex-1 px-3 py-2 rounded-lg border bg-background text-sm"
                        />
                        <button
                            onClick={() => testWebhook('teams')}
                            disabled={!settings.teams_webhook_url || testing === 'teams'}
                            className="px-3 py-2 rounded-lg bg-muted hover:bg-muted/80 disabled:opacity-50 transition-colors"
                        >
                            <TestTube className={`w-4 h-4 ${testing === 'teams' ? 'animate-pulse' : ''}`} />
                        </button>
                    </div>
                </div>
            </div>

            {/* Event toggles */}
            <div className="pt-4 border-t space-y-3">
                <h3 className="text-sm font-medium">Send varsler når:</h3>

                <label className="flex items-center gap-3">
                    <input
                        type="checkbox"
                        checked={settings.notify_on_signup}
                        onChange={(e) => setSettings({ ...settings, notify_on_signup: e.target.checked })}
                        className="w-4 h-4 rounded border-gray-300"
                    />
                    <span className="text-sm">Ny bruker registrerer seg</span>
                </label>

                <label className="flex items-center gap-3">
                    <input
                        type="checkbox"
                        checked={settings.notify_on_course_complete}
                        onChange={(e) => setSettings({ ...settings, notify_on_course_complete: e.target.checked })}
                        className="w-4 h-4 rounded border-gray-300"
                    />
                    <span className="text-sm">Bruker fullfører et kurs</span>
                </label>

                <label className="flex items-center gap-3">
                    <input
                        type="checkbox"
                        checked={settings.notify_on_quiz_pass}
                        onChange={(e) => setSettings({ ...settings, notify_on_quiz_pass: e.target.checked })}
                        className="w-4 h-4 rounded border-gray-300"
                    />
                    <span className="text-sm">Bruker består en quiz</span>
                </label>

                <label className="flex items-center gap-3">
                    <input
                        type="checkbox"
                        checked={settings.notify_on_comment}
                        onChange={(e) => setSettings({ ...settings, notify_on_comment: e.target.checked })}
                        className="w-4 h-4 rounded border-gray-300"
                    />
                    <span className="text-sm">Ny kommentar på leksjon</span>
                </label>
            </div>

            {/* Save button */}
            <button
                onClick={saveSettings}
                disabled={saving}
                className="w-full flex items-center justify-center gap-2 px-4 py-3 rounded-lg bg-primary text-primary-foreground font-medium hover:bg-primary/90 disabled:opacity-50 transition-colors"
            >
                <Save className="w-4 h-4" />
                {saving ? 'Lagrer...' : 'Lagre innstillinger'}
            </button>
        </div>
    );
}
