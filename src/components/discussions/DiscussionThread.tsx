'use client';

import { useState } from 'react';
import { ArrowLeft, ThumbsUp, Reply, User, MoreHorizontal, Trash2, Flag } from 'lucide-react';
import { useTranslations } from 'next-intl';
import { formatDistanceToNow } from 'date-fns';
import { nb, enUS } from 'date-fns/locale';

interface DiscussionReply {
    id: string;
    content: string;
    user_id: string;
    author_name: string;
    author_avatar?: string;
    parent_reply_id?: string;
    is_solution: boolean;
    like_count: number;
    created_at: string;
}

interface DiscussionDetail {
    id: string;
    title: string;
    content: string;
    is_pinned: boolean;
    is_locked: boolean;
    author_name: string;
    author_avatar?: string;
    user_id: string;
    like_count: number;
    created_at: string;
    replies: DiscussionReply[];
}

interface DiscussionThreadProps {
    discussion: DiscussionDetail;
    currentUserId?: string;
    locale?: 'no' | 'en';
    onBack?: () => void;
    onReply?: (content: string, parentReplyId?: string) => void;
    onLike?: (discussionId?: string, replyId?: string) => void;
    onDelete?: (replyId: string) => void;
}

export function DiscussionThread({
    discussion,
    currentUserId,
    locale = 'no',
    onBack,
    onReply,
    onLike,
    onDelete
}: DiscussionThreadProps) {
    const t = useTranslations('discussions');
    const [replyContent, setReplyContent] = useState('');
    const [replyingTo, setReplyingTo] = useState<string | null>(null);

    const handleSubmitReply = () => {
        if (!replyContent.trim()) return;
        onReply?.(replyContent, replyingTo || undefined);
        setReplyContent('');
        setReplyingTo(null);
    };

    const renderReply = (reply: DiscussionReply, depth: number = 0) => {
        const childReplies = discussion.replies.filter(r => r.parent_reply_id === reply.id);
        const isOwner = currentUserId === reply.user_id;

        return (
            <div key={reply.id} className={`${depth > 0 ? 'ml-8 border-l-2 border-zinc-200 dark:border-zinc-700 pl-4' : ''}`}>
                <div className="py-4">
                    <div className="flex items-start gap-3">
                        {/* Avatar */}
                        <div className="
                            w-8 h-8 shrink-0
                            bg-zinc-200 dark:bg-zinc-700
                            border-2 border-black dark:border-white
                            flex items-center justify-center
                            overflow-hidden
                        ">
                            {reply.author_avatar ? (
                                <img src={reply.author_avatar} alt="" className="w-full h-full object-cover" />
                            ) : (
                                <User className="w-4 h-4 text-zinc-500" />
                            )}
                        </div>

                        <div className="flex-1">
                            <div className="flex items-center gap-2 mb-1">
                                <span className="font-bold text-sm">{reply.author_name}</span>
                                <span className="text-xs text-zinc-500">
                                    {formatDistanceToNow(new Date(reply.created_at), {
                                        addSuffix: true,
                                        locale: locale === 'no' ? nb : enUS
                                    })}
                                </span>
                                {reply.is_solution && (
                                    <span className="px-2 py-0.5 bg-green-500 text-white text-xs font-bold uppercase">
                                        {t('solution')}
                                    </span>
                                )}
                            </div>

                            <p className="text-sm whitespace-pre-wrap">{reply.content}</p>

                            <div className="flex items-center gap-3 mt-2">
                                <button
                                    onClick={() => onLike?.(undefined, reply.id)}
                                    className="flex items-center gap-1 text-xs text-zinc-500 hover:text-black dark:hover:text-white"
                                >
                                    <ThumbsUp className="w-3 h-3" />
                                    {reply.like_count}
                                </button>
                                {!discussion.is_locked && (
                                    <button
                                        onClick={() => setReplyingTo(reply.id)}
                                        className="flex items-center gap-1 text-xs text-zinc-500 hover:text-black dark:hover:text-white"
                                    >
                                        <Reply className="w-3 h-3" />
                                        {t('reply')}
                                    </button>
                                )}
                                {isOwner && (
                                    <button
                                        onClick={() => onDelete?.(reply.id)}
                                        className="flex items-center gap-1 text-xs text-red-500 hover:text-red-600"
                                    >
                                        <Trash2 className="w-3 h-3" />
                                    </button>
                                )}
                            </div>
                        </div>
                    </div>
                </div>

                {/* Child replies */}
                {childReplies.map(child => renderReply(child, depth + 1))}
            </div>
        );
    };

    const topLevelReplies = discussion.replies.filter(r => !r.parent_reply_id);

    return (
        <div className="space-y-4">
            {/* Back Button */}
            <button
                onClick={onBack}
                className="
                    flex items-center gap-2
                    text-sm font-bold uppercase
                    text-zinc-600 dark:text-zinc-400
                    hover:text-black dark:hover:text-white
                    transition-colors
                "
            >
                <ArrowLeft className="w-4 h-4" />
                {t('back_to_list')}
            </button>

            {/* Discussion Header */}
            <div className="
                p-6
                bg-white dark:bg-zinc-900
                border-3 border-black dark:border-white
                shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] dark:shadow-[4px_4px_0px_0px_rgba(255,255,255,1)]
            ">
                <h1 className="text-2xl font-black mb-4">{discussion.title}</h1>

                <div className="flex items-center gap-3 mb-4">
                    <div className="
                        w-10 h-10
                        bg-zinc-200 dark:bg-zinc-700
                        border-2 border-black dark:border-white
                        flex items-center justify-center
                        overflow-hidden
                    ">
                        {discussion.author_avatar ? (
                            <img src={discussion.author_avatar} alt="" className="w-full h-full object-cover" />
                        ) : (
                            <User className="w-5 h-5 text-zinc-500" />
                        )}
                    </div>
                    <div>
                        <span className="font-bold">{discussion.author_name}</span>
                        <span className="text-sm text-zinc-500 ml-2">
                            {formatDistanceToNow(new Date(discussion.created_at), {
                                addSuffix: true,
                                locale: locale === 'no' ? nb : enUS
                            })}
                        </span>
                    </div>
                </div>

                <p className="whitespace-pre-wrap">{discussion.content}</p>

                <div className="flex items-center gap-4 mt-4 pt-4 border-t border-zinc-200 dark:border-zinc-700">
                    <button
                        onClick={() => onLike?.(discussion.id)}
                        className="flex items-center gap-1 text-sm text-zinc-500 hover:text-black dark:hover:text-white"
                    >
                        <ThumbsUp className="w-4 h-4" />
                        {discussion.like_count} {t('likes')}
                    </button>
                </div>
            </div>

            {/* Replies */}
            <div className="
                bg-white dark:bg-zinc-900
                border-3 border-black dark:border-white
                shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] dark:shadow-[4px_4px_0px_0px_rgba(255,255,255,1)]
            ">
                <div className="p-4 border-b border-zinc-200 dark:border-zinc-700">
                    <h3 className="font-bold uppercase text-sm">
                        {t('replies')} ({discussion.replies.length})
                    </h3>
                </div>

                <div className="divide-y divide-zinc-200 dark:divide-zinc-700 px-4">
                    {topLevelReplies.length === 0 ? (
                        <p className="py-8 text-center text-zinc-500">{t('no_replies')}</p>
                    ) : (
                        topLevelReplies.map(reply => renderReply(reply))
                    )}
                </div>
            </div>

            {/* Reply Form */}
            {!discussion.is_locked && (
                <div className="
                    p-4
                    bg-white dark:bg-zinc-900
                    border-3 border-black dark:border-white
                    shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] dark:shadow-[4px_4px_0px_0px_rgba(255,255,255,1)]
                ">
                    {replyingTo && (
                        <div className="mb-2 text-sm text-zinc-500 flex items-center justify-between">
                            <span>{t('replying_to')}</span>
                            <button
                                onClick={() => setReplyingTo(null)}
                                className="text-xs text-red-500"
                            >
                                {t('cancel')}
                            </button>
                        </div>
                    )}
                    <textarea
                        value={replyContent}
                        onChange={(e) => setReplyContent(e.target.value)}
                        placeholder={t('write_reply')}
                        className="
                            w-full p-3 min-h-[100px]
                            bg-zinc-50 dark:bg-zinc-800
                            border-2 border-black dark:border-white
                            font-medium
                            resize-none
                            focus:outline-none focus:ring-2 focus:ring-blue-500
                        "
                    />
                    <button
                        onClick={handleSubmitReply}
                        disabled={!replyContent.trim()}
                        className="
                            mt-2 px-4 py-2
                            bg-black dark:bg-white
                            text-white dark:text-black
                            font-bold uppercase text-sm
                            border-2 border-black dark:border-white
                            disabled:opacity-50 disabled:cursor-not-allowed
                            hover:shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:-translate-x-0.5 hover:-translate-y-0.5
                            transition-all duration-200
                        "
                    >
                        {t('post_reply')}
                    </button>
                </div>
            )}
        </div>
    );
}
