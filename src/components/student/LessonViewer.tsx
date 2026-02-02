'use client';

import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import { FileText, Download, PlayCircle, BookOpen, LightbulbIcon, MessageSquare } from 'lucide-react';
import QuizTaker from './QuizTaker';

interface LessonViewerProps {
    lesson: any;
    userId: string;
}

export default function LessonViewer({ lesson, userId }: LessonViewerProps) {
    const contentBlocks = lesson.lesson_content?.sort((a: any, b: any) => a.order_index - b.order_index) || [];

    // Check if lesson has direct content (markdown string from migrations)
    const hasDirectContent = lesson.content && lesson.content.trim().length > 0;
    // Check if lesson has content blocks (from lesson_content table)
    const hasContentBlocks = contentBlocks.length > 0;

    return (
        <div className="max-w-4xl mx-auto px-4 sm:px-6 py-8">
            {/* Lesson Header Card */}
            <div className="bg-gradient-to-br from-primary/10 via-primary/5 to-transparent 
                            border-2 border-black dark:border-white rounded-lg p-6 mb-8">
                <div className="flex items-start gap-4">
                    <div className="p-3 bg-primary/20 rounded-lg">
                        <BookOpen className="w-6 h-6 text-primary" />
                    </div>
                    <div className="flex-1">
                        <h1 className="text-2xl sm:text-3xl font-bold mb-2">{lesson.title}</h1>
                        {lesson.description && (
                            <p className="text-muted-foreground text-sm sm:text-base">{lesson.description}</p>
                        )}
                        {lesson.duration_minutes && (
                            <div className="flex items-center gap-2 mt-3 text-sm text-muted-foreground">
                                <div className="flex items-center gap-1.5 bg-muted px-3 py-1 rounded-full">
                                    <span>⏱️</span>
                                    <span>{lesson.duration_minutes} minutt</span>
                                </div>
                            </div>
                        )}
                    </div>
                </div>
            </div>

            {/* Video Placeholder (for future video content) */}
            {lesson.video_url ? (
                <div className="mb-8 rounded-lg overflow-hidden border-2 border-black dark:border-white">
                    {lesson.video_url.includes('youtube.com') || lesson.video_url.includes('youtu.be') ? (
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

            {/* Main Content Section */}
            <div className="space-y-8">
                {/* Direct Content (from lessons.content column) */}
                {hasDirectContent && (
                    <div className="bg-background border-2 border-black dark:border-white rounded-lg p-6 sm:p-8">
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
                                    <div className="bg-background border-2 border-black dark:border-white rounded-lg p-6 sm:p-8">
                                        <div className="prose dark:prose-invert prose-table:border-2 prose-table:border-foreground/20 prose-th:bg-muted prose-th:p-3 prose-th:border prose-td:p-3 prose-td:border max-w-none">
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
                                        className="flex items-center gap-4 p-4 bg-background border-2 border-black dark:border-white 
                                                   rounded-lg hover:bg-muted transition-colors group"
                                    >
                                        <div className="p-3 bg-primary/10 rounded-lg group-hover:bg-primary/20 transition-colors">
                                            <Download className="w-6 h-6 text-primary" />
                                        </div>
                                        <div className="flex-1">
                                            <p className="font-medium">{block.file_name || 'Last ned fil'}</p>
                                            <p className="text-sm text-muted-foreground">Klikk for å laste ned</p>
                                        </div>
                                    </a>
                                )}
                            </div>
                        ))}
                    </div>
                )}

                {/* Key Takeaways Section */}
                {hasDirectContent && (
                    <div className="bg-gradient-to-r from-amber-500/10 to-amber-500/5 
                                    border-2 border-amber-500/50 rounded-lg p-6">
                        <div className="flex items-start gap-3">
                            <LightbulbIcon className="w-5 h-5 text-amber-500 mt-0.5 shrink-0" />
                            <div>
                                <h3 className="font-bold text-amber-700 dark:text-amber-400 mb-2">Hugs dette 💡</h3>
                                <p className="text-sm text-muted-foreground">
                                    Ta deg tid til å reflektere over det du har lært. Korleis kan du bruke dette i din kvardag?
                                </p>
                            </div>
                        </div>
                    </div>
                )}
            </div>

            {/* Quiz Section */}
            <div className="mt-12 pt-8 border-t-2 border-black dark:border-white">
                <div className="flex items-center gap-3 mb-6">
                    <div className="p-2 bg-primary/10 rounded-lg">
                        <MessageSquare className="w-5 h-5 text-primary" />
                    </div>
                    <h2 className="text-xl font-bold">Quiz</h2>
                </div>
                <QuizTaker lessonId={lesson.id} userId={userId} />
            </div>
        </div>
    );
}
