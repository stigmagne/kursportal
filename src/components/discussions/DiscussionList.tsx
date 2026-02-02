'use client';

import { useState } from 'react';
import { MessageSquare, Pin, Lock, ThumbsUp, ChevronDown, ChevronUp, User } from 'lucide-react';
import { useTranslations } from 'next-intl';
import { formatDistanceToNow } from 'date-fns';
import { nb, enUS } from 'date-fns/locale';

interface Discussion {
    id: string;
    title: string;
    content: string;
    is_pinned: boolean;
    is_locked: boolean;
    reply_count: number;
    like_count: number;
    view_count: number;
    created_at: string;
    author_name: string;
    author_avatar?: string;
}

interface DiscussionListProps {
    discussions: Discussion[];
    courseId: string;
    locale?: 'no' | 'en';
    onDiscussionClick?: (id: string) => void;
    onNewDiscussion?: () => void;
}

export function DiscussionList({
    discussions,
    courseId,
    locale = 'no',
    onDiscussionClick,
    onNewDiscussion
}: DiscussionListProps) {
    const t = useTranslations('discussions');
    const [sortBy, setSortBy] = useState<'newest' | 'popular' | 'active'>('newest');

    const sortedDiscussions = [...discussions].sort((a, b) => {
        // Pinned always first
        if (a.is_pinned && !b.is_pinned) return -1;
        if (!a.is_pinned && b.is_pinned) return 1;

        switch (sortBy) {
            case 'popular':
                return b.like_count - a.like_count;
            case 'active':
                return b.reply_count - a.reply_count;
            default:
                return new Date(b.created_at).getTime() - new Date(a.created_at).getTime();
        }
    });

    return (
        <div className="space-y-4">
            {/* Header */}
            <div className="flex items-center justify-between">
                <h2 className="text-xl font-black uppercase tracking-tight">
                    {t('title')}
                </h2>
                <button
                    onClick={onNewDiscussion}
                    className="
                        px-4 py-2
                        bg-black dark:bg-white
                        text-white dark:text-black
                        font-bold uppercase text-sm
                        border-3 border-black dark:border-white
                        shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] dark:shadow-[4px_4px_0px_0px_rgba(255,255,255,1)]
                        hover:shadow-[6px_6px_0px_0px_rgba(0,0,0,1)] hover:-translate-x-0.5 hover:-translate-y-0.5
                        transition-all duration-200
                    "
                >
                    {t('new_discussion')}
                </button>
            </div>

            {/* Sort Options */}
            <div className="flex gap-2">
                {(['newest', 'popular', 'active'] as const).map((option) => (
                    <button
                        key={option}
                        onClick={() => setSortBy(option)}
                        className={`
                            px-3 py-1
                            text-xs font-bold uppercase
                            border-2 border-black dark:border-white
                            transition-all duration-200
                            ${sortBy === option
                                ? 'bg-black dark:bg-white text-white dark:text-black'
                                : 'bg-white dark:bg-zinc-900 hover:bg-zinc-100 dark:hover:bg-zinc-800'
                            }
                        `}
                    >
                        {t(`sort_${option}`)}
                    </button>
                ))}
            </div>

            {/* Discussion List */}
            <div className="space-y-3">
                {sortedDiscussions.length === 0 ? (
                    <div className="
                        p-8 text-center
                        border-2 border-dashed border-zinc-300 dark:border-zinc-700
                        rounded-none
                    ">
                        <MessageSquare className="w-12 h-12 mx-auto mb-3 text-zinc-400" />
                        <p className="text-zinc-500">{t('no_discussions')}</p>
                    </div>
                ) : (
                    sortedDiscussions.map((discussion) => (
                        <button
                            key={discussion.id}
                            onClick={() => onDiscussionClick?.(discussion.id)}
                            className="
                                w-full text-left p-4
                                bg-white dark:bg-zinc-900
                                border-3 border-black dark:border-white
                                shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] dark:shadow-[4px_4px_0px_0px_rgba(255,255,255,1)]
                                hover:shadow-[6px_6px_0px_0px_rgba(0,0,0,1)] hover:-translate-x-0.5 hover:-translate-y-0.5
                                transition-all duration-200
                            "
                        >
                            <div className="flex items-start gap-3">
                                {/* Avatar */}
                                <div className="
                                    w-10 h-10 shrink-0
                                    bg-zinc-200 dark:bg-zinc-700
                                    border-2 border-black dark:border-white
                                    flex items-center justify-center
                                    overflow-hidden
                                ">
                                    {discussion.author_avatar ? (
                                        <img
                                            src={discussion.author_avatar}
                                            alt={discussion.author_name}
                                            className="w-full h-full object-cover"
                                        />
                                    ) : (
                                        <User className="w-5 h-5 text-zinc-500" />
                                    )}
                                </div>

                                {/* Content */}
                                <div className="flex-1 min-w-0">
                                    <div className="flex items-center gap-2 mb-1">
                                        {discussion.is_pinned && (
                                            <Pin className="w-4 h-4 text-orange-500" />
                                        )}
                                        {discussion.is_locked && (
                                            <Lock className="w-4 h-4 text-zinc-400" />
                                        )}
                                        <h3 className="font-bold text-lg truncate">
                                            {discussion.title}
                                        </h3>
                                    </div>

                                    <p className="text-sm text-zinc-600 dark:text-zinc-400 line-clamp-2">
                                        {discussion.content}
                                    </p>

                                    <div className="flex items-center gap-4 mt-2 text-xs text-zinc-500">
                                        <span>{discussion.author_name}</span>
                                        <span>
                                            {formatDistanceToNow(new Date(discussion.created_at), {
                                                addSuffix: true,
                                                locale: locale === 'no' ? nb : enUS
                                            })}
                                        </span>
                                        <span className="flex items-center gap-1">
                                            <MessageSquare className="w-3 h-3" />
                                            {discussion.reply_count}
                                        </span>
                                        <span className="flex items-center gap-1">
                                            <ThumbsUp className="w-3 h-3" />
                                            {discussion.like_count}
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </button>
                    ))
                )}
            </div>
        </div>
    );
}
