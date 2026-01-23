'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/utils/supabase/client';
import { MessageSquare, Reply, Trash2, Send } from 'lucide-react';
import { formatDistanceToNow } from 'date-fns';
import { nb } from 'date-fns/locale';
import { useLocale, useTranslations } from 'next-intl';
import { showToast } from '@/lib/toast';

interface Comment {
    id: string;
    content: string;
    created_at: string;
    user_id: string;
    user: {
        id: string;
        full_name: string;
        avatar_url: string | null;
    };
    replies?: Comment[];
}

interface LessonCommentsProps {
    lessonId: string;
}

export function LessonComments({ lessonId }: LessonCommentsProps) {
    const [comments, setComments] = useState<Comment[]>([]);
    const [newComment, setNewComment] = useState('');
    const [replyTo, setReplyTo] = useState<string | null>(null);
    const [isLoading, setIsLoading] = useState(true);
    const [isPosting, setIsPosting] = useState(false);
    const supabase = createClient();
    const locale = useLocale();
    const t = useTranslations('Comments');

    useEffect(() => {
        fetchComments();
    }, [lessonId]);

    const fetchComments = async () => {
        const { data } = await supabase
            .from('lesson_comments')
            .select(`
        id,
        content,
        created_at,
        parent_id,
        user_id,
        user:profiles!user_id(id, full_name, avatar_url)
      `)
            .eq('lesson_id', lessonId)
            .order('created_at', { ascending: false });

        if (data) {
            // Organize into parent-child structure
            const parentComments = data.filter(c => !c.parent_id);
            const organized = parentComments.map(parent => ({
                ...parent,
                replies: data
                    .filter(c => c.parent_id === parent.id)
                    .sort((a, b) => new Date(a.created_at).getTime() - new Date(b.created_at).getTime()),
            }));
            setComments(organized as any);
        }
        setIsLoading(false);
    };

    const postComment = async () => {
        if (!newComment.trim()) return;

        const { data: user } = await supabase.auth.getUser();
        if (!user.user) {
            showToast.error(t('login_required'));
            return;
        }

        setIsPosting(true);

        const { error } = await supabase
            .from('lesson_comments')
            .insert({
                lesson_id: lessonId,
                user_id: user.user.id,
                parent_id: replyTo,
                content: newComment.trim(),
            });

        if (!error) {
            setNewComment('');
            setReplyTo(null);
            fetchComments();
            showToast.success(t('comment_posted'));
        } else {
            showToast.error(t('error_posting'));
        }

        setIsPosting(false);
    };

    const deleteComment = async (id: string) => {
        const { error } = await supabase
            .from('lesson_comments')
            .delete()
            .eq('id', id);

        if (!error) {
            fetchComments();
            showToast.success(t('comment_deleted'));
        } else {
            showToast.error(t('error_deleting'));
        }
    };

    return (
        <div className="bg-white text-gray-900 rounded-xl p-6 space-y-6 border border-gray-200">
            <h3 className="text-xl font-semibold flex items-center gap-2">
                <MessageSquare className="w-5 h-5" />
                {t('title')} ({comments.length})
            </h3>

            {/* New Comment Form */}
            <div className="space-y-3">
                {replyTo && (
                    <div className="flex items-center gap-2 text-sm text-gray-600">
                        <Reply className="w-4 h-4" />
                        {t('replying_to')}
                        <button
                            onClick={() => setReplyTo(null)}
                            className="text-blue-600 hover:underline"
                        >
                            {t('cancel')}
                        </button>
                    </div>
                )}
                <textarea
                    value={newComment}
                    onChange={(e) => setNewComment(e.target.value)}
                    placeholder={t('placeholder')}
                    className="w-full px-4 py-3 bg-white border border-gray-300 rounded-lg resize-none focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-900"
                    rows={3}
                />
                <button
                    onClick={postComment}
                    disabled={!newComment.trim() || isPosting}
                    className="px-4 py-2 bg-blue-600 text-white rounded-lg font-medium hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
                >
                    <Send className="w-4 h-4" />
                    {isPosting ? t('posting') : t('post')}
                </button>
            </div>

            {/* Comments List */}
            {isLoading ? (
                <div className="space-y-4">
                    {[1, 2, 3].map(i => (
                        <div key={i} className="h-24 bg-gray-100 rounded animate-pulse" />
                    ))}
                </div>
            ) : comments.length === 0 ? (
                <p className="text-center text-gray-500 py-8">
                    {t('no_comments')}
                </p>
            ) : (
                <div className="space-y-4">
                    {comments.map(comment => (
                        <CommentItem
                            key={comment.id}
                            comment={comment}
                            onReply={setReplyTo}
                            onDelete={deleteComment}
                            locale={locale}
                            t={t}
                        />
                    ))}
                </div>
            )}
        </div>
    );
}

interface CommentItemProps {
    comment: Comment;
    onReply: (id: string) => void;
    onDelete: (id: string) => void;
    locale: string;
    t: any;
    isReply?: boolean;
}

function CommentItem({ comment, onReply, onDelete, locale, t, isReply = false }: CommentItemProps) {
    const [currentUser, setCurrentUser] = useState<any>(null);
    const supabase = createClient();

    useEffect(() => {
        supabase.auth.getUser().then(({ data }) => setCurrentUser(data.user));
    }, []);

    return (
        <div className={`${isReply ? 'ml-12' : ''}`}>
            <div className="flex gap-3">
                <div className="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center shrink-0">
                    {comment.user.avatar_url ? (
                        <img
                            src={comment.user.avatar_url}
                            alt={comment.user.full_name}
                            className="w-full h-full rounded-full object-cover"
                        />
                    ) : (
                        <span className="text-sm font-medium text-blue-600">
                            {comment.user.full_name.charAt(0).toUpperCase()}
                        </span>
                    )}
                </div>

                <div className="flex-1 space-y-2">
                    <div className="flex items-center gap-2">
                        <span className="font-medium text-gray-900">{comment.user.full_name}</span>
                        <span className="text-xs text-gray-500">
                            {formatDistanceToNow(new Date(comment.created_at), {
                                addSuffix: true,
                                locale: locale === 'no' ? nb : undefined,
                            })}
                        </span>
                    </div>

                    <p className="text-sm text-gray-700">{comment.content}</p>

                    <div className="flex items-center gap-4 text-sm">
                        <button
                            onClick={() => onReply(comment.id)}
                            className="text-gray-600 hover:text-blue-600 flex items-center gap-1"
                        >
                            <Reply className="w-4 h-4" />
                            {t('reply')}
                        </button>

                        {currentUser?.id === comment.user_id && (
                            <button
                                onClick={() => onDelete(comment.id)}
                                className="text-gray-600 hover:text-red-600 flex items-center gap-1"
                            >
                                <Trash2 className="w-4 h-4" />
                                {t('delete')}
                            </button>
                        )}
                    </div>
                </div>
            </div>

            {/* Replies */}
            {comment.replies && comment.replies.length > 0 && (
                <div className="mt-4 space-y-4">
                    {comment.replies.map((reply: Comment) => (
                        <CommentItem
                            key={reply.id}
                            comment={reply}
                            onReply={onReply}
                            onDelete={onDelete}
                            locale={locale}
                            t={t}
                            isReply
                        />
                    ))}
                </div>
            )}
        </div>
    );
}
