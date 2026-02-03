'use server';

import { createClient } from '@/utils/supabase/server';
import { revalidatePath } from 'next/cache';

export async function createDiscussion(courseId: string, title: string, content: string) {
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();

    if (!user) {
        throw new Error('Unauthorized');
    }

    const { error } = await supabase
        .from('course_discussions')
        .insert({
            course_id: courseId,
            user_id: user.id,
            title,
            content
        });

    if (error) {
        console.error('Error creating discussion:', error);
        throw new Error('Failed to create discussion');
    }

    revalidatePath(`/courses/${courseId}`);
}

export async function replyToDiscussion(discussionId: string, content: string, parentReplyId?: string) {
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();

    if (!user) {
        throw new Error('Unauthorized');
    }

    const { error } = await supabase
        .from('discussion_replies')
        .insert({
            discussion_id: discussionId,
            user_id: user.id,
            content,
            parent_reply_id: parentReplyId
        });

    if (error) {
        console.error('Error replying to discussion:', error);
        throw new Error('Failed to reply');
    }

    revalidatePath(`/courses/[id]`, 'page'); // Simple revalidate for now, ideally targeted
}

export async function toggleLike(discussionId?: string, replyId?: string) {
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();

    if (!user) {
        throw new Error('Unauthorized');
    }

    if (discussionId) {
        // Toggle like for discussion
        const { data: existingLike } = await supabase
            .from('discussion_likes')
            .select('id')
            .eq('user_id', user.id)
            .eq('discussion_id', discussionId)
            .single();

        if (existingLike) {
            await supabase
                .from('discussion_likes')
                .delete()
                .eq('id', existingLike.id);
        } else {
            await supabase
                .from('discussion_likes')
                .insert({
                    user_id: user.id,
                    discussion_id: discussionId
                });
        }
    } else if (replyId) {
        // Toggle like for reply
        const { data: existingLike } = await supabase
            .from('discussion_likes')
            .select('id')
            .eq('user_id', user.id)
            .eq('reply_id', replyId)
            .single();

        if (existingLike) {
            await supabase
                .from('discussion_likes')
                .delete()
                .eq('id', existingLike.id);
        } else {
            await supabase
                .from('discussion_likes')
                .insert({
                    user_id: user.id,
                    reply_id: replyId
                });
        }
    }

    revalidatePath(`/courses/[id]`, 'page');
}

export async function deleteDiscussion(discussionId: string) {
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();

    if (!user) throw new Error('Unauthorized');

    const { error } = await supabase
        .from('course_discussions')
        .delete()
        .eq('id', discussionId)
        .eq('user_id', user.id); // RLS enforces this too, but good as extra check

    if (error) {
        console.error('Error deleting discussion:', error);
        throw new Error('Failed to delete discussion');
    }

    revalidatePath(`/courses/[id]`, 'page');
}

export async function deleteReply(replyId: string) {
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();

    if (!user) throw new Error('Unauthorized');

    const { error } = await supabase
        .from('discussion_replies')
        .delete()
        .eq('id', replyId)
        .eq('user_id', user.id);

    if (error) {
        console.error('Error deleting reply:', error);
        throw new Error('Failed to delete reply');
    }

    revalidatePath(`/courses/[id]`, 'page');
}
