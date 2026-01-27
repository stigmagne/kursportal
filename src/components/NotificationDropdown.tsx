'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/utils/supabase/client';
import { Link } from '@/i18n/routing';
import { formatDistanceToNow } from 'date-fns';
import { nb } from 'date-fns/locale';
import { useLocale, useTranslations } from 'next-intl';

interface Notification {
    id: string;
    type: string;
    title: string;
    message: string | null;
    link: string | null;
    read: boolean;
    created_at: string;
}

interface NotificationDropdownProps {
    onClose: () => void;
    onRead: () => void;
}

export function NotificationDropdown({ onClose, onRead }: NotificationDropdownProps) {
    const [notifications, setNotifications] = useState<Notification[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const supabase = createClient();
    const locale = useLocale();
    const t = useTranslations('Notifications');

    useEffect(() => {
        fetchNotifications();
    }, []);

    const fetchNotifications = async () => {
        const { data: user } = await supabase.auth.getUser();
        if (!user.user) return;

        const { data } = await supabase
            .from('notifications')
            .select('*')
            .eq('user_id', user.user.id)
            .order('created_at', { ascending: false })
            .limit(10);

        if (data) setNotifications(data);
        setIsLoading(false);
    };

    const markAsRead = async (id: string) => {
        await supabase
            .from('notifications')
            .update({ read: true })
            .eq('id', id);

        setNotifications(prev =>
            prev.map(n => (n.id === id ? { ...n, read: true } : n))
        );
        onRead();
    };

    const markAllAsRead = async () => {
        const { data: user } = await supabase.auth.getUser();
        if (!user.user) return;

        await supabase
            .from('notifications')
            .update({ read: true })
            .eq('user_id', user.user.id)
            .eq('read', false);

        setNotifications(prev => prev.map(n => ({ ...n, read: true })));
        onRead();
    };

    return (
        <>
            {/* Backdrop */}
            <div
                className="fixed inset-0 z-40"
                onClick={onClose}
            />

            {/* Dropdown */}
            <div className="absolute right-0 mt-2 w-96 bg-white text-gray-900 border-2 border-black rounded-none shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] z-50 max-h-[500px] overflow-hidden flex flex-col">
                {/* Header */}
                <div className="p-4 border-b border-gray-200 bg-gray-50 flex items-center justify-between">
                    <h3 className="font-semibold">{t('title')}</h3>
                    {notifications.some(n => !n.read) && (
                        <button
                            onClick={markAllAsRead}
                            className="text-sm text-primary hover:underline"
                        >
                            {t('mark_all_read')}
                        </button>
                    )}
                </div>

                {/* Notifications List */}
                <div className="overflow-y-auto flex-1">
                    {isLoading ? (
                        <div className="p-4 space-y-3">
                            {[1, 2, 3].map(i => (
                                <div key={i} className="h-16 bg-muted rounded-none animate-pulse" />
                            ))}
                        </div>
                    ) : notifications.length === 0 ? (
                        <div className="p-8 text-center text-muted-foreground">
                            {t('no_notifications')}
                        </div>
                    ) : (
                        notifications.map(notification => (
                            <div
                                key={notification.id}
                                className={`p-4 border-b border-gray-200 hover:bg-gray-50 transition-colors ${!notification.read ? 'bg-blue-50' : ''
                                    }`}
                            >
                                {notification.link ? (
                                    <Link
                                        href={notification.link}
                                        onClick={() => {
                                            markAsRead(notification.id);
                                            onClose();
                                        }}
                                        className="block"
                                    >
                                        <NotificationContent notification={notification} locale={locale} />
                                    </Link>
                                ) : (
                                    <div onClick={() => markAsRead(notification.id)}>
                                        <NotificationContent notification={notification} locale={locale} />
                                    </div>
                                )}
                            </div>
                        ))
                    )}
                </div>
            </div>
        </>
    );
}

function NotificationContent({ notification, locale }: { notification: Notification; locale: string }) {
    return (
        <>
            <div className="flex items-start justify-between gap-2">
                <h4 className="font-medium">{notification.title}</h4>
                {!notification.read && (
                    <span className="w-2 h-2 bg-primary rounded-full shrink-0 mt-2" />
                )}
            </div>
            {notification.message && (
                <p className="text-sm text-muted-foreground mt-1">
                    {notification.message}
                </p>
            )}
            <p className="text-xs text-muted-foreground mt-2">
                {formatDistanceToNow(new Date(notification.created_at), {
                    addSuffix: true,
                    locale: locale === 'no' ? nb : undefined,
                })}
            </p>
        </>
    );
}
