'use client';

import { useState } from 'react';
import { CourseContentTabs } from './CourseContentTabs';
import { CourseModulesList } from './CourseModulesList';
import { DiscussionList } from '@/components/discussions/DiscussionList';
import { DiscussionThread } from '@/components/discussions/DiscussionThread';
import { NewDiscussionForm } from '@/components/discussions/NewDiscussionForm';
import { createDiscussion, replyToDiscussion, toggleLike, deleteDiscussion, deleteReply } from '@/actions/discussions';
import { useRouter } from 'next/navigation';
import { useTranslations } from 'next-intl';

interface CourseContentWrapperProps {
    courseId: string;
    modules: any[];
    discussions: any[];
    currentUserId: string;
    locale: string;
}

export function CourseContentWrapper({
    courseId,
    modules,
    discussions,
    currentUserId,
    locale
}: CourseContentWrapperProps) {
    const [activeTab, setActiveTab] = useState<'content' | 'discussions'>('content');
    const [view, setView] = useState<'list' | 'create' | 'detail'>('list');
    const [selectedDiscussionId, setSelectedDiscussionId] = useState<string | null>(null);
    const router = useRouter();

    const selectedDiscussion = discussions.find(d => d.id === selectedDiscussionId);

    const handleNewDiscussion = () => {
        setView('create');
    };

    const handleDiscussionClick = (id: string) => {
        setSelectedDiscussionId(id);
        setView('detail');
    };

    const handleCreateSubmit = async (title: string, content: string) => {
        await createDiscussion(courseId, title, content);
        setView('list');
        router.refresh();
    };

    const handleReply = async (content: string, parentReplyId?: string) => {
        if (!selectedDiscussionId) return;
        await replyToDiscussion(selectedDiscussionId, content, parentReplyId);
        router.refresh();
    };

    const handleLike = async (discussionId?: string, replyId?: string) => {
        await toggleLike(discussionId, replyId);
        router.refresh();
    };

    const handleDelete = async (replyId: string) => {
        if (confirm('Are you sure you want to delete this reply?')) {
            await deleteReply(replyId);
            router.refresh();
        }
    };

    // Transform discussion data for DiscussionList if needed
    // The query in CoursePage needs to match what DiscussionList expects.
    // Assuming 'discussions' prop matches the required shape or we map it here.

    // DiscussionThread needs a slightly different structure (with full replies array).
    // The 'discussions' prop from server should probably include replies for the detail view to work immediately 
    // OR we need to fetch replies separately. 
    // For simplicity, let's assume we fetch everything or we accept that selecting a discussion triggers a refresh/fetch?
    // Actually, passing all data at once for all discussions is heavy if there are many replies.
    // BUT, the prompt implies "integrated".
    // Better approach: In 'detail' view, we might rely on the data we have.
    // Let's assume 'discussions' prop contains the needed fields for the list.
    // For the DETAIL view, we might strictly need 'replies'.
    // If 'discussions' prop passed to this wrapper ALREADY has replies, great.
    // content: discussion.content

    return (
        <div>
            <CourseContentTabs
                activeTab={activeTab}
                onTabChange={(tab) => {
                    setActiveTab(tab);
                    if (tab === 'content') setView('list');
                }}
                discussionCount={discussions.length}
            />

            {activeTab === 'content' && (
                <CourseModulesList modules={modules} courseId={courseId} />
            )}

            {activeTab === 'discussions' && (
                <div>
                    {view === 'list' && (
                        <DiscussionList
                            discussions={discussions}
                            courseId={courseId}
                            locale={locale as 'no' | 'en'}
                            onDiscussionClick={handleDiscussionClick}
                            onNewDiscussion={handleNewDiscussion}
                        />
                    )}

                    {view === 'create' && (
                        <NewDiscussionForm
                            courseId={courseId}
                            onSubmit={handleCreateSubmit}
                            onCancel={() => setView('list')}
                        />
                    )}

                    {view === 'detail' && selectedDiscussion && (
                        <DiscussionThread
                            discussion={selectedDiscussion}
                            currentUserId={currentUserId}
                            locale={locale as 'no' | 'en'}
                            onBack={() => {
                                setView('list');
                                setSelectedDiscussionId(null);
                            }}
                            onReply={handleReply}
                            onLike={handleLike}
                            onDelete={handleDelete}
                        />
                    )}
                </div>
            )}
        </div>
    );
}
