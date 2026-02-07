'use client';

import { useState, useMemo } from 'react';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import {
    FileText, Download, PlayCircle, BookOpen, Lightbulb,
    MessageSquare, Clock, BookMarked, List, CheckSquare
} from 'lucide-react';
import QuizTaker from './QuizTaker';
import { CaseStudyView } from './CaseStudyView';
import { ExpertVideoView } from './ExpertVideoView';

interface LessonViewerProps {
    lesson: any;
    userId: string;
}

// Parse content into sections based on h2 headers
function parseContentSections(content: string): { title: string; content: string; icon: string }[] {
    if (!content || content.trim().length === 0) return [];

    // Split by h2 headers (## Title)
    const sections: { title: string; content: string; icon: string }[] = [];
    const lines = content.split('\n');
    let currentSection = { title: 'Introduksjon', content: '', icon: 'book' };

    for (const line of lines) {
        if (line.startsWith('## ')) {
            // Save previous section if it has content
            if (currentSection.content.trim()) {
                sections.push({ ...currentSection });
            }
            // Start new section
            const title = line.replace('## ', '').trim();
            currentSection = {
                title,
                content: '',
                icon: getIconForSection(title)
            };
        } else {
            currentSection.content += line + '\n';
        }
    }

    // Add last section
    if (currentSection.content.trim()) {
        sections.push(currentSection);
    }

    // If only one section or no h2 found, return as single section
    if (sections.length <= 1) {
        return [{ title: 'Innhold', content, icon: 'book' }];
    }

    return sections;
}

function getIconForSection(title: string): string {
    const lower = title.toLowerCase();
    if (lower.includes('introduksjon') || lower.includes('innledning')) return 'book';
    if (lower.includes('oppsummer') || lower.includes('konklusjon')) return 'check';
    if (lower.includes('praktisk') || lower.includes('øvelse')) return 'list';
    if (lower.includes('husk') || lower.includes('tips')) return 'lightbulb';
    return 'bookmark';
}

function SectionIcon({ icon, className }: { icon: string; className?: string }) {
    switch (icon) {
        case 'book': return <BookOpen className={className} />;
        case 'check': return <CheckSquare className={className} />;
        case 'list': return <List className={className} />;
        case 'lightbulb': return <Lightbulb className={className} />;
        default: return <BookMarked className={className} />;
    }
}

export default function LessonViewer({ lesson, userId }: LessonViewerProps) {
    const contentBlocks = lesson.lesson_content?.sort((a: any, b: any) => a.order_index - b.order_index) || [];

    // Check if lesson has direct content (markdown string from migrations)
    const hasDirectContent = lesson.content && lesson.content.trim().length > 0;
    // Check if lesson has content blocks (from lesson_content table)
    const hasContentBlocks = contentBlocks.length > 0;

    // Parse content into sections for tabs
    const sections = useMemo(() => {
        if (hasDirectContent) {
            return parseContentSections(lesson.content);
        }
        return [];
    }, [lesson.content, hasDirectContent]);

    const [activeTab, setActiveTab] = useState(0);
    const showTabs = sections.length > 1;

    return (
        <div className="max-w-4xl mx-auto px-4 sm:px-6 py-8">
            {/* Lesson Header Card */}
            <div className="bg-linear-to-br from-primary/10 via-primary/5 to-transparent 
                            border-2 border-black dark:border-white rounded-lg p-6 mb-8">
                <div className="flex items-start gap-4">
                    <div className="p-3 bg-primary/20 rounded-lg border-2 border-black dark:border-white">
                        <BookOpen className="w-6 h-6 text-primary" />
                    </div>
                    <div className="flex-1">
                        <h1 className="text-2xl sm:text-3xl font-bold mb-2">{lesson.title}</h1>
                        {lesson.description && (
                            <p className="text-muted-foreground text-sm sm:text-base">{lesson.description}</p>
                        )}
                        {lesson.duration_minutes && (
                            <div className="flex items-center gap-2 mt-3 text-sm text-muted-foreground">
                                <div className="flex items-center gap-1.5 bg-muted px-3 py-1 rounded-lg border border-black/20 dark:border-white/20">
                                    <Clock className="w-4 h-4" />
                                    <span>{lesson.duration_minutes} minutt</span>
                                </div>
                            </div>
                        )}
                    </div>
                </div>
            </div>

            {/* Video Section */}
            {lesson.video_url ? (
                <div className="mb-8 rounded-lg overflow-hidden border-2 border-black dark:border-white">
                    {lesson.video_url.includes('vimeo.com') ? (
                        <iframe
                            src={lesson.video_url.replace('vimeo.com/', 'player.vimeo.com/video/')}
                            className="w-full aspect-video"
                            allow="autoplay; fullscreen; picture-in-picture"
                            allowFullScreen
                        />
                    ) : lesson.video_url.includes('youtube.com') || lesson.video_url.includes('youtu.be') ? (
                        <iframe
                            src={lesson.video_url.replace('watch?v=', 'embed/').replace('youtu.be/', 'youtube.com/embed/')}
                            className="w-full aspect-video"
                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                            allowFullScreen
                        />
                    ) : (
                        <video src={lesson.video_url} controls className="w-full aspect-video" />
                    )}
                </div>
            ) : (
                /* Video placeholder for lessons without video */
                <div className="mb-8 bg-muted/30 border-2 border-dashed border-muted-foreground/30 
                                rounded-lg p-8 flex flex-col items-center justify-center text-center">
                    <PlayCircle className="w-12 h-12 text-muted-foreground/50 mb-3" />
                    <p className="text-sm text-muted-foreground">Video kjem snart</p>
                </div>
            )}

            {/* Main Content Section with Tabs */}
            <div className="space-y-8">
                {/* Tab Navigation (only show if multiple sections) */}
                {showTabs && (
                    <div className="flex flex-wrap gap-2 border-b-2 border-black dark:border-white pb-4">
                        {sections.map((section, index) => (
                            <button
                                key={index}
                                onClick={() => setActiveTab(index)}
                                className={`flex items-center gap-2 px-4 py-2 rounded-lg font-medium transition-all border-2 ${activeTab === index
                                    ? 'bg-primary text-primary-foreground border-black dark:border-white shadow-[4px_4px_0_0_#000] dark:shadow-[4px_4px_0_0_#fff]'
                                    : 'bg-muted hover:bg-muted/80 border-transparent hover:border-black/20 dark:hover:border-white/20'
                                    }`}
                            >
                                <SectionIcon icon={section.icon} className="w-4 h-4" />
                                <span className="hidden sm:inline">{section.title}</span>
                                <span className="sm:hidden">{index + 1}</span>
                            </button>
                        ))}
                    </div>
                )}

                {/* Direct Content (from lessons.content column) */}
                {hasDirectContent && (
                    <div className="bg-white dark:bg-zinc-900 border-2 border-black dark:border-white rounded-lg p-6 sm:p-8 shadow-[4px_4px_0_0_#000] dark:shadow-[4px_4px_0_0_#fff]">
                        {showTabs ? (
                            // Show only active section
                            <div className="prose dark:prose-invert prose-headings:font-bold 
                                            prose-h2:text-xl prose-h2:border-b-2 prose-h2:border-primary/30 prose-h2:pb-2 prose-h2:mb-4
                                            prose-h3:text-lg prose-h3:text-primary
                                            prose-ul:list-disc prose-ul:pl-5
                                            prose-blockquote:border-l-4 prose-blockquote:border-primary prose-blockquote:bg-primary/5 prose-blockquote:py-2 prose-blockquote:px-4 prose-blockquote:italic
                                            prose-strong:text-primary
                                            prose-table:border-2 prose-table:border-foreground/20
                                            prose-th:bg-muted prose-th:p-3 prose-th:border prose-th:border-foreground/20
                                            prose-td:p-3 prose-td:border prose-td:border-foreground/20
                                            max-w-none">
                                <h2 className="flex items-center gap-2">
                                    <SectionIcon icon={sections[activeTab].icon} className="w-5 h-5" />
                                    {sections[activeTab].title}
                                </h2>
                                <ReactMarkdown remarkPlugins={[remarkGfm]}>{sections[activeTab].content}</ReactMarkdown>
                            </div>
                        ) : (
                            // Show all content if no tabs
                            <div className="prose dark:prose-invert prose-headings:font-bold 
                                            prose-h2:text-xl prose-h2:border-b-2 prose-h2:border-primary/30 prose-h2:pb-2 prose-h2:mb-4
                                            prose-h3:text-lg prose-h3:text-primary
                                            prose-ul:list-disc prose-ul:pl-5
                                            prose-blockquote:border-l-4 prose-blockquote:border-primary prose-blockquote:bg-primary/5 prose-blockquote:py-2 prose-blockquote:px-4 prose-blockquote:italic
                                            prose-strong:text-primary
                                            prose-table:border-2 prose-table:border-foreground/20
                                            prose-th:bg-muted prose-th:p-3 prose-th:border prose-th:border-foreground/20
                                            prose-td:p-3 prose-td:border prose-td:border-foreground/20
                                            max-w-none">
                                <ReactMarkdown remarkPlugins={[remarkGfm]}>{lesson.content}</ReactMarkdown>
                            </div>
                        )}

                        {/* Tab Navigation Dots/Arrows at bottom */}
                        {showTabs && (
                            <div className="flex items-center justify-between mt-6 pt-4 border-t border-muted">
                                <button
                                    onClick={() => setActiveTab(Math.max(0, activeTab - 1))}
                                    disabled={activeTab === 0}
                                    className="px-4 py-2 rounded-lg border-2 border-black dark:border-white font-medium disabled:opacity-30 disabled:cursor-not-allowed hover:bg-muted transition-colors"
                                >
                                    Forrige seksjon
                                </button>
                                <div className="flex gap-2">
                                    {sections.map((_, index) => (
                                        <button
                                            key={index}
                                            onClick={() => setActiveTab(index)}
                                            className={`w-3 h-3 rounded-full border-2 border-black dark:border-white transition-colors ${activeTab === index ? 'bg-primary' : 'bg-muted'
                                                }`}
                                        />
                                    ))}
                                </div>
                                <button
                                    onClick={() => setActiveTab(Math.min(sections.length - 1, activeTab + 1))}
                                    disabled={activeTab === sections.length - 1}
                                    className="px-4 py-2 rounded-lg border-2 border-black dark:border-white bg-primary text-primary-foreground font-medium disabled:opacity-30 disabled:cursor-not-allowed hover:bg-primary/90 transition-colors"
                                >
                                    Neste seksjon
                                </button>
                            </div>
                        )}
                    </div>
                )}

                {/* Content Blocks (from lesson_content table) */}
                {!hasDirectContent && !hasContentBlocks ? (
                    <div className="text-center py-16 border-2 border-dashed border-muted-foreground/30 rounded-lg">
                        <FileText className="w-12 h-12 mx-auto mb-4 text-muted-foreground/50" />
                        <p className="text-muted-foreground">Ikkje noko innhald tilgjengeleg enno.</p>
                    </div>
                ) : hasContentBlocks && (
                    <div className="space-y-6">
                        {contentBlocks.map((block: any) => (
                            <div key={block.id} className="content-block">
                                {block.type === 'text' && block.text_content && (
                                    <div className="bg-white dark:bg-zinc-900 border-2 border-black dark:border-white rounded-lg p-6 sm:p-8 shadow-[4px_4px_0_0_#000] dark:shadow-[4px_4px_0_0_#fff]">
                                        <div className="prose dark:prose-invert prose-headings:font-bold 
                                                        prose-h2:text-xl prose-h2:border-b-2 prose-h2:border-primary/30 prose-h2:pb-2 prose-h2:mb-4
                                                        prose-h3:text-lg prose-h3:text-primary
                                                        prose-ul:list-disc prose-ul:pl-5
                                                        prose-blockquote:border-l-4 prose-blockquote:border-primary prose-blockquote:bg-primary/5 prose-blockquote:py-2 prose-blockquote:px-4 prose-blockquote:italic
                                                        prose-strong:text-primary
                                                        prose-table:border-2 prose-table:border-foreground/20
                                                        prose-th:bg-muted prose-th:p-3 prose-th:border prose-th:border-foreground/20
                                                        prose-td:p-3 prose-td:border prose-td:border-foreground/20
                                                        max-w-none">
                                            <ReactMarkdown remarkPlugins={[remarkGfm]}>{block.text_content}</ReactMarkdown>
                                        </div>
                                    </div>
                                )}

                                {block.type === 'video' && block.video_url && (
                                    <div className="rounded-lg overflow-hidden border-2 border-black dark:border-white">
                                        {block.video_url.includes('youtube.com') || block.video_url.includes('youtu.be') ? (
                                            <iframe
                                                src={block.video_url.replace('watch?v=', 'embed/').replace('youtu.be/', 'youtube.com/embed/')}
                                                className="w-full aspect-video"
                                                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                                                allowFullScreen
                                            />
                                        ) : block.video_url.includes('vimeo.com') ? (
                                            <iframe
                                                src={block.video_url.replace('vimeo.com/', 'player.vimeo.com/video/')}
                                                className="w-full aspect-video"
                                                allow="autoplay; fullscreen; picture-in-picture"
                                                allowFullScreen
                                            />
                                        ) : (
                                            <video src={block.video_url} controls className="w-full aspect-video" />
                                        )}
                                    </div>
                                )}

                                {block.type === 'file' && block.file_url && (
                                    <a
                                        href={block.file_url}
                                        download={block.file_name}
                                        target="_blank"
                                        rel="noopener noreferrer"
                                        className="flex items-center gap-4 p-4 bg-white dark:bg-zinc-900 border-2 border-black dark:border-white 
                                                   rounded-lg hover:bg-muted transition-colors group shadow-[4px_4px_0_0_#000] dark:shadow-[4px_4px_0_0_#fff]"
                                    >
                                        <div className="p-3 bg-primary/10 rounded-lg group-hover:bg-primary/20 transition-colors border-2 border-black dark:border-white">
                                            <Download className="w-6 h-6 text-primary" />
                                        </div>
                                        <div className="flex-1">
                                            <p className="font-medium">{block.file_name || 'Last ned fil'}</p>
                                            <p className="text-sm text-muted-foreground">Klikk for å laste ned</p>
                                        </div>
                                    </a>
                                )}

                                {block.type === 'expert_video' && block.expert_video_data && (
                                    <ExpertVideoView data={block.expert_video_data} />
                                )}
                            </div>
                        ))}
                    </div>
                )}

                {/* Key Takeaways Section */}
                {
                    hasDirectContent && (
                        <div className="bg-amber-50 dark:bg-amber-950/30 border-2 border-amber-500 rounded-lg p-6 shadow-[4px_4px_0_0_#f59e0b]">
                            <div className="flex items-start gap-3">
                                <div className="p-2 bg-amber-500/20 rounded-lg border-2 border-amber-500">
                                    <Lightbulb className="w-5 h-5 text-amber-600 dark:text-amber-400" />
                                </div>
                                <div>
                                    <h3 className="font-bold text-amber-700 dark:text-amber-400 mb-2">Hugs dette</h3>
                                    <p className="text-sm text-amber-800 dark:text-amber-200">
                                        Ta deg tid til å reflektere over det du har lært. Korleis kan du bruke dette i din kvardag?
                                    </p>
                                </div>
                            </div>
                        </div>
                    )
                }
            </div>

            {/* Quiz Section */}
            <div className="mt-12 pt-8 border-t-2 border-black dark:border-white">
                <div className="flex items-center gap-3 mb-6">
                    <div className="p-2 bg-primary/10 rounded-lg border-2 border-black dark:border-white">
                        <MessageSquare className="w-5 h-5 text-primary" />
                    </div>
                    <h2 className="text-xl font-bold">Quiz</h2>
                </div>
                <QuizTaker lessonId={lesson.id} userId={userId} />
            </div>
        </div>
    );
}
