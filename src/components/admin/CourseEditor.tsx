'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { Loader2, Save, ArrowLeft, Plus, Eye, Upload, X, Tag } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { createClient } from '@/utils/supabase/client';
import ReactMarkdown from 'react-markdown';
import ModuleManager from '@/components/admin/ModuleManager';
import EnrollmentManager from '@/components/admin/EnrollmentManager';
import { useTranslations } from 'next-intl';

type Tab = 'editor' | 'modules' | 'enrollments' | 'preview';

export default function CourseEditor({ courseId }: { courseId?: string }) {
    const t = useTranslations('CourseEditor');
    const router = useRouter();
    const supabase = createClient();
    const [isLoading, setIsLoading] = useState(!!courseId);
    const [isSaving, setIsSaving] = useState(false);
    const [saveSuccess, setSaveSuccess] = useState(false);
    const [activeTab, setActiveTab] = useState<Tab>('editor');
    const [tags, setTags] = useState<any[]>([]);
    const [selectedTags, setSelectedTags] = useState<string[]>([]);
    const [selectedUserCategories, setSelectedUserCategories] = useState<string[]>([]); // Target Groups

    // Form State
    const [title, setTitle] = useState('');
    const [description, setDescription] = useState('');
    const [content, setContent] = useState('');
    const [published, setPublished] = useState(false);
    const [coverImage, setCoverImage] = useState('');

    useEffect(() => {
        fetchTags();
        if (courseId) {
            fetchCourse();
        }
    }, [courseId]);

    const fetchTags = async () => {
        const { data } = await supabase.from('tags').select('*').order('name');
        setTags(data || []);
    };

    const fetchCourse = async () => {
        try {
            const { data: course } = await supabase
                .from('courses')
                .select('*')
                .eq('id', courseId)
                .single();

            if (course) {
                setTitle(course.title);
                setDescription(course.description || '');
                setContent(course.content || '');
                setPublished(course.published);
                setCoverImage(course.cover_image || '');

                // Fetch course tags
                const { data: courseTags } = await supabase
                    .from('course_tags')
                    .select('tag_id')
                    .eq('course_id', courseId);

                setSelectedTags(courseTags?.map(ct => ct.tag_id) || []);

                // Fetch target groups (from courses table column)
                // Note: 'target_groups' is a text[] column on the courses table
                // However, we already fetched 'course' above, so we can access it directly if it was selected.
                // But the initial select query was just '*', which includes target_groups.
                // Let's ensure we use the fetched course data.

                if (course.target_groups) {
                    setSelectedUserCategories(course.target_groups);
                } else {
                    // Fallback to course_user_categories if target_groups is empty (legacy support)
                    // Or just default to []
                    setSelectedUserCategories([]);
                }
            }
        } catch (error) {
            console.error('Error fetching course:', error);
        } finally {
            setIsLoading(false);
        }
    };

    const handleCoverUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        try {
            const fileExt = file.name.split('.').pop();
            const fileName = `course-cover-${Date.now()}.${fileExt}`;
            const filePath = `course-covers/${fileName}`;

            const { error: uploadError } = await supabase.storage
                .from('course-images')
                .upload(filePath, file);

            if (uploadError) throw uploadError;

            const { data: { publicUrl } } = supabase.storage
                .from('course-images')
                .getPublicUrl(filePath);

            setCoverImage(publicUrl);
        } catch (error: any) {
            alert('Error uploading image: ' + error.message);
        }
    };

    const handleSave = async () => {
        if (!title.trim()) {
            alert('Please enter a course title');
            return;
        }

        setIsSaving(true);

        try {
            const user = (await supabase.auth.getUser()).data.user;
            if (!user) throw new Error('No user found');

            const courseData = {
                title,
                description,
                content,
                published,
                cover_image: coverImage,
                author_id: user.id,
                target_groups: selectedUserCategories // Save directly to column
            };

            let savedCourseId = courseId;

            if (courseId) {
                // Update existing course
                const { error } = await supabase
                    .from('courses')
                    .update(courseData)
                    .eq('id', courseId);

                if (error) throw error;
            } else {
                // Create new course
                const { data, error } = await supabase
                    .from('courses')
                    .insert(courseData)
                    .select()
                    .single();

                if (error) throw error;
                savedCourseId = data.id;
            }

            if (savedCourseId) {
                // Update TAGS
                await supabase
                    .from('course_tags')
                    .delete()
                    .eq('course_id', savedCourseId);

                if (selectedTags.length > 0) {
                    const tagAssignments = selectedTags.map(tagId => ({
                        course_id: savedCourseId,
                        tag_id: tagId
                    }));

                    await supabase
                        .from('course_tags')
                        .insert(tagAssignments);
                }

                // Note: We no longer saving to 'course_user_categories' table as it is replaced by 'target_groups' column.
            }

            setSaveSuccess(true);
            setTimeout(() => setSaveSuccess(false), 3000);

            // If creating new course, redirect to edit page
            if (!courseId && savedCourseId) {
                router.push(`/admin/courses/edit/${savedCourseId}`);
            } else {
                // Just refresh to update data
                router.refresh();
            }
        } catch (error: any) {
            console.error('Error saving course:', error);
            alert('Failed to save course: ' + error.message);
        } finally {
            setIsSaving(false);
        }
    };

    const toggleTag = (tagId: string) => {
        setSelectedTags(prev =>
            prev.includes(tagId)
                ? prev.filter(id => id !== tagId)
                : [...prev, tagId]
        );
    };

    if (isLoading) {
        return (
            <div className="flex items-center justify-center py-12">
                <Loader2 className="w-8 h-8 animate-spin text-primary" />
            </div>
        );
    }

    return (
        <div className="max-w-5xl mx-auto space-y-6">
            {/* Header */}
            <div className="flex items-center justify-between mb-6">
                <div className="flex items-center gap-4">
                    <Link
                        href="/admin/courses"
                        className="p-2 hover:bg-muted rounded-md transition-colors"
                        title={t('back')}
                    >
                        <ArrowLeft className="w-5 h-5" />
                    </Link>
                    <h1 className="text-2xl font-bold">
                        {courseId ? t('edit_title') : t('create_title')}
                    </h1>
                    {saveSuccess && (
                        <span className="text-sm text-green-600 dark:text-green-400 animate-in fade-in">
                            {t('saved')}
                        </span>
                    )}
                </div>
                <div className="flex items-center gap-3">
                    {courseId && (
                        <Link
                            href={`/courses/${courseId}`}
                            target="_blank"
                            className="px-4 py-2 rounded-lg border border-border hover:bg-muted transition-colors flex items-center gap-2"
                        >
                            <Eye className="w-4 h-4" />
                            {t('preview')}
                        </Link>
                    )}
                    <Link
                        href="/admin/courses"
                        className="px-4 py-2 rounded-lg border border-border hover:bg-muted transition-colors"
                    >
                        {t('back')}
                    </Link>
                    <button
                        onClick={handleSave}
                        disabled={isSaving}
                        className="px-4 py-2 bg-primary text-primary-foreground rounded-lg font-medium hover:bg-primary/90 disabled:opacity-50 flex items-center gap-2"
                    >
                        {isSaving ? (
                            <>
                                <Loader2 className="w-4 h-4 animate-spin" />
                                {t('saving')}
                            </>
                        ) : (
                            <>
                                <Save className="w-4 h-4" />
                                {courseId ? t('update_btn') : t('create_btn')}
                            </>
                        )}
                    </button>
                </div>
            </div>

            {/* Tabs */}
            <div className="border-b border-border">
                <div className="flex gap-6">
                    {(['editor', 'modules', 'enrollments', 'preview'] as Tab[]).map((tab) => (
                        <button
                            key={tab}
                            onClick={() => setActiveTab(tab)}
                            className={`px-4 py-3 font-medium capitalize transition-colors border-b-2 ${activeTab === tab
                                ? 'border-primary text-primary'
                                : 'border-transparent text-muted-foreground hover:text-foreground'
                                }`}
                        >
                            {t(`tabs.${tab}` as any)}
                        </button>
                    ))}
                </div>
            </div>

            {/* Tab Content */}
            <div className="glass rounded-2xl border border-white/10 p-8">
                {activeTab === 'editor' && (
                    <div className="space-y-8">
                        {/* Content Section */}
                        <div className="space-y-6">
                            <h3 className="text-lg font-semibold border-b border-border pb-2">{t('sections.content')}</h3>

                            <div>
                                <label className="block text-sm font-medium mb-2">{t('fields.title')}</label>
                                <input
                                    type="text"
                                    value={title}
                                    onChange={(e) => setTitle(e.target.value)}
                                    className="w-full px-4 py-3 rounded-lg bg-muted border border-border focus:border-primary focus:outline-none text-lg"
                                    placeholder={t('placeholders.title')}
                                />
                            </div>

                            <div>
                                <label className="block text-sm font-medium mb-2">{t('fields.description')}</label>
                                <textarea
                                    value={description}
                                    onChange={(e) => setDescription(e.target.value)}
                                    rows={3}
                                    className="w-full px-4 py-3 rounded-lg bg-muted border border-border focus:border-primary focus:outline-none resize-none"
                                    placeholder={t('placeholders.description')}
                                />
                            </div>

                            <div>
                                <label className="block text-sm font-medium mb-2">{t('fields.content')}</label>
                                <textarea
                                    value={content}
                                    onChange={(e) => setContent(e.target.value)}
                                    rows={15}
                                    className="w-full px-4 py-3 rounded-lg bg-muted border border-border focus:border-primary focus:outline-none font-mono text-sm resize-none"
                                    placeholder={t('placeholders.content')}
                                />
                                <p className="text-xs text-muted-foreground mt-2">
                                    Supports Markdown formatting. Use the Preview tab to see how it looks.
                                </p>
                            </div>
                        </div>

                        {/* Settings Section */}
                        <div className="space-y-6 pt-6 border-t border-border">
                            <h3 className="text-lg font-semibold border-b border-border pb-2">{t('sections.settings')}</h3>

                            <div>
                                <label className="block text-sm font-medium mb-3">{t('fields.cover')}</label>
                                {coverImage ? (
                                    <div className="relative w-full aspect-video rounded-lg overflow-hidden bg-muted group">
                                        <img src={coverImage} alt="Cover" className="w-full h-full object-cover" />
                                        <button
                                            onClick={() => setCoverImage('')}
                                            className="absolute top-2 right-2 p-2 bg-destructive text-destructive-foreground rounded-md opacity-0 group-hover:opacity-100 transition-opacity"
                                        >
                                            <X className="w-4 h-4" />
                                        </button>
                                    </div>
                                ) : (
                                    <label className="w-full aspect-video rounded-lg border-2 border-dashed border-border hover:border-primary transition-colors cursor-pointer bg-muted/30 flex flex-col items-center justify-center group">
                                        <Upload className="w-12 h-12 text-muted-foreground group-hover:text-primary transition-colors" />
                                        <span className="text-sm text-muted-foreground mt-2">Click to upload cover image</span>
                                        <input
                                            type="file"
                                            accept="image/*"
                                            className="hidden"
                                            onChange={handleCoverUpload}
                                        />
                                    </label>
                                )}
                            </div>

                            <div className={`flex items-center justify-between p-6 rounded-xl border-2 transition-all ${published
                                ? 'bg-green-500/10 border-green-500/20'
                                : 'bg-yellow-500/10 border-yellow-500/20'
                                }`}>
                                <div>
                                    <h4 className={`text-lg font-semibold ${published ? 'text-green-700 dark:text-green-400' : 'text-yellow-700 dark:text-yellow-400'}`}>
                                        {published ? '✅ ' + t('fields.publish_status') : '⚠️ ' + t('fields.publish_status')}
                                    </h4>
                                    <p className="text-muted-foreground mt-1">
                                        {published ? t('status.visible') : t('status.hidden')}
                                    </p>
                                </div>
                                <button
                                    onClick={() => setPublished(!published)}
                                    className={`px-6 py-3 rounded-lg font-bold shadow-lg transition-all transform hover:scale-105 active:scale-95 ${published
                                        ? 'bg-background hover:bg-muted text-foreground border border-border'
                                        : 'bg-primary text-primary-foreground hover:bg-primary/90'
                                        }`}
                                >
                                    {published ? 'Avpubliser (Gjør til utkast)' : 'PUBLISER KURS'}
                                </button>
                            </div>

                            {courseId && (
                                <div className="pt-4 border-t border-border">
                                    <Link
                                        href={`/admin/courses/${courseId}/quiz/new`}
                                        className="flex items-center gap-2 px-4 py-2 bg-secondary text-secondary-foreground rounded-lg font-medium hover:bg-secondary/80 transition-colors w-fit"
                                    >
                                        <Plus className="w-4 h-4" />
                                        {t('add_quiz')}
                                    </Link>
                                </div>
                            )}
                        </div>

                        {/* Target Groups Section */}
                        <div className="space-y-6 pt-6 border-t border-border">
                            <h3 className="text-lg font-semibold border-b border-border pb-2">Målgrupper (Target Groups)</h3>
                            <p className="text-sm text-muted-foreground">
                                Velg hvem dette kurset er ment for. Dette styrer hvem som har tilgang til kurset.
                            </p>

                            <div className="grid gap-3 md:grid-cols-2 lg:grid-cols-3">
                                {[
                                    { value: 'sibling', label: 'Søsken', desc: 'For voksne søsken' },
                                    { value: 'parent', label: 'Foreldre', desc: 'For foreldre/foresatte' },
                                    { value: 'team-member', label: 'Teammedlem', desc: 'For ansatte i team' },
                                    { value: 'team-leader', label: 'Teamleder', desc: 'For ledere og mellomledere' },
                                    { value: 'construction_worker', label: 'Håndverker', desc: 'For fagarbeidere i bygg' },
                                    { value: 'site_manager', label: 'Bas/Byggeleder', desc: 'For byggledelse' },
                                ].map((group) => (
                                    <button
                                        key={group.value}
                                        onClick={() => {
                                            setSelectedUserCategories(prev =>
                                                prev.includes(group.value)
                                                    ? prev.filter(g => g !== group.value)
                                                    : [...prev, group.value]
                                            );
                                        }}
                                        className={`p-4 border-2 transition-all text-left ${selectedUserCategories.includes(group.value)
                                            ? 'border-primary bg-primary/10 shadow-[2px_2px_0_0_#000] dark:shadow-[2px_2px_0_0_#fff]'
                                            : 'border-black/30 dark:border-white/30 hover:border-black dark:hover:border-white'
                                            }`}
                                    >
                                        <div className="flex items-center gap-3">
                                            <div className="flex-1">
                                                <h4 className="font-bold">{group.label}</h4>
                                                <p className="text-xs text-muted-foreground">{group.desc}</p>
                                            </div>
                                            {selectedUserCategories.includes(group.value) && (
                                                <div className="w-5 h-5 bg-primary flex items-center justify-center shrink-0">
                                                    <svg className="w-3 h-3 text-primary-foreground" fill="currentColor" viewBox="0 0 20 20">
                                                        <path d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" />
                                                    </svg>
                                                </div>
                                            )}
                                        </div>
                                    </button>
                                ))}
                            </div>
                            <p className="text-xs text-muted-foreground italic mt-2">
                                Merk: Nye målgrupper kan legges til av systemadministrator ved behov.
                            </p>
                        </div>

                        {/* Tags Section */}
                        <div className="space-y-6 pt-6 border-t border-border">
                            <h3 className="text-lg font-semibold border-b border-border pb-2">Tags</h3>
                            <p className="text-sm text-muted-foreground">
                                Velg tags for å gjøre det enklere å finne kurset.
                            </p>

                            {tags.length === 0 ? (
                                <div className="text-center py-8 text-muted-foreground">
                                    <p>Ingen tags funnet</p>
                                    <Link href="/admin/tags" className="text-primary hover:underline mt-2 inline-block">
                                        Opprett tags
                                    </Link>
                                </div>
                            ) : (
                                <div className="flex flex-wrap gap-2">
                                    {tags.map((tag) => (
                                        <button
                                            key={tag.id}
                                            onClick={() => toggleTag(tag.id)}
                                            className={`flex items-center gap-2 px-3 py-1.5 rounded-full border transition-all ${selectedTags.includes(tag.id)
                                                ? 'bg-primary text-primary-foreground border-primary'
                                                : 'bg-muted hover:bg-muted/80 border-transparent'
                                                }`}
                                        >
                                            <Tag className="w-3 h-3" />
                                            <span className="text-sm font-medium">{tag.name}</span>
                                        </button>
                                    ))}
                                </div>
                            )}

                            {selectedTags.length === 0 && tags.length > 0 && (
                                <div className="p-4 rounded-lg bg-yellow-500/10 border border-yellow-500/30 text-yellow-600 dark:text-yellow-400 text-sm">
                                    {t('warnings.no_selection')}
                                </div>
                            )}
                        </div>
                    </div>
                )}

                {/* Modules Tab */}
                {activeTab === 'modules' && (
                    <div className="space-y-6">
                        {!courseId ? (
                            <div className="text-center py-12 text-muted-foreground glass rounded-xl border border-white/10 p-8">
                                <p className="text-lg font-medium mb-2">{t('warnings.save_first')}</p>
                                <p className="text-sm">{t('warnings.save_first_desc')}</p>
                            </div>
                        ) : (
                            <ModuleManager courseId={courseId} />
                        )}
                    </div>
                )}

                {/* Enrollments Tab */}
                {activeTab === 'enrollments' && (
                    <div className="space-y-6">
                        {!courseId ? (
                            <div className="text-center py-12 text-muted-foreground glass rounded-xl border border-white/10 p-8">
                                <p className="text-lg font-medium mb-2">{t('warnings.save_first')}</p>
                                <p className="text-sm">{t('warnings.save_first_desc')}</p>
                            </div>
                        ) : (
                            <EnrollmentManager courseId={courseId} />
                        )}
                    </div>
                )}

                {/* Preview Tab */}
                {activeTab === 'preview' && (
                    <div className="space-y-6">
                        <div className="flex items-center justify-between mb-4">
                            <h3 className="text-lg font-semibold">Course Preview</h3>
                            <span className="text-sm text-muted-foreground">How members will see it</span>
                        </div>

                        {coverImage && (
                            <div className="aspect-video rounded-lg overflow-hidden bg-muted">
                                <img src={coverImage} alt="Cover" className="w-full h-full object-cover" />
                            </div>
                        )}

                        <div>
                            <h1 className="text-4xl font-bold mb-4">{title || 'Untitled Course'}</h1>
                            <p className="text-lg text-muted-foreground mb-6">{description || 'No description provided'}</p>
                        </div>

                        {selectedTags.length > 0 && (
                            <div className="flex flex-wrap gap-2 mb-6">
                                {tags
                                    .filter(t => selectedTags.includes(t.id))
                                    .map(tag => (
                                        <span
                                            key={tag.id}
                                            className="px-3 py-1 rounded-full text-sm font-medium border bg-primary/10 text-primary border-primary/20"
                                        >
                                            {tag.name}
                                        </span>
                                    ))}
                            </div>
                        )}

                        <hr className="border-border" />

                        <div className="prose prose-invert prose-lg max-w-none">
                            {content ? (
                                <ReactMarkdown>{content}</ReactMarkdown>
                            ) : (
                                <p className="text-muted-foreground italic">No content yet. Add content in the Content tab.</p>
                            )}
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
}
