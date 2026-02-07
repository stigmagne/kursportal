'use client';

import { useState, useMemo } from 'react';
import { Link } from '@/i18n/routing';
import { BookOpen, ArrowRight, X, Tag, Filter } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

interface Course {
    id: string;
    title: string;
    description: string | null;
    tags: string[]; // slugs
}

interface Tag {
    id: string;
    name: string;
    slug: string;
}

interface CourseListProps {
    initialCourses: Course[];
    availableTags: Tag[];
    translations: {
        start_course: string;
        no_courses: string;
        filter_by_tags: string;
        clear_filters: string;
        no_results: string;
    };
}

export default function CourseList({ initialCourses, availableTags, translations }: CourseListProps) {
    const [selectedTags, setSelectedTags] = useState<string[]>([]);

    // Filter courses based on selected tags
    const filteredCourses = useMemo(() => {
        if (selectedTags.length === 0) return initialCourses;

        return initialCourses.filter(course =>
            // Show course if it matches ANY of the selected tags (OR filtering)
            // Alternatively, use EVERY for AND filtering. OR is usually better for tags.
            selectedTags.some(tagSlug => course.tags.includes(tagSlug))
        );
    }, [initialCourses, selectedTags]);

    const toggleTag = (tagSlug: string) => {
        setSelectedTags(prev =>
            prev.includes(tagSlug)
                ? prev.filter(t => t !== tagSlug)
                : [...prev, tagSlug]
        );
    };

    const clearFilters = () => setSelectedTags([]);

    return (
        <div className="space-y-8">
            {/* Filter Section */}
            <div className="flex flex-col items-center space-y-4">
                <div className="flex items-center gap-2 text-muted-foreground">
                    <Filter className="w-4 h-4" />
                    <span className="text-sm font-medium">{translations.filter_by_tags}</span>
                </div>

                <div className="flex flex-wrap justify-center gap-2 max-w-2xl">
                    {availableTags.map(tag => (
                        <button
                            key={tag.id}
                            onClick={() => toggleTag(tag.slug)}
                            className={`
                                inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-sm font-medium transition-all
                                ${selectedTags.includes(tag.slug)
                                    ? 'bg-primary text-primary-foreground shadow-md scale-105'
                                    : 'bg-muted/50 text-muted-foreground hover:bg-muted hover:text-foreground'
                                }
                            `}
                        >
                            <Tag className="w-3 h-3" />
                            {tag.name}
                            {selectedTags.includes(tag.slug) && <X className="w-3 h-3 ml-1" />}
                        </button>
                    ))}
                </div>

                {selectedTags.length > 0 && (
                    <button
                        onClick={clearFilters}
                        className="text-sm text-muted-foreground hover:text-primary transition-colors underline decoration-dotted underline-offset-4"
                    >
                        {translations.clear_filters}
                    </button>
                )}
            </div>

            {/* Results Count */}
            <div className="text-center text-sm text-muted-foreground">
                {filteredCourses.length} {filteredCourses.length === 1 ? 'kurs' : 'kurs'}
            </div>

            {/* Course Grid */}
            <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-3">
                <AnimatePresence mode="popLayout">
                    {filteredCourses.map((course) => (
                        <motion.div
                            key={course.id}
                            layout
                            initial={{ opacity: 0, scale: 0.9 }}
                            animate={{ opacity: 1, scale: 1 }}
                            exit={{ opacity: 0, scale: 0.9 }}
                            transition={{ duration: 0.2 }}
                            className="group flex flex-col bg-background overflow-hidden border-4 border-black dark:border-white shadow-[8px_8px_0px_0px_rgba(0,0,0,1)] dark:shadow-[8px_8px_0px_0px_rgba(255,255,255,1)] hover:translate-x-[2px] hover:translate-y-[2px] hover:shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] dark:hover:shadow-[4px_4px_0px_0px_rgba(255,255,255,1)] transition-all"
                        >
                            <div className="aspect-video bg-primary/10 flex items-center justify-center relative overflow-hidden border-b-4 border-black dark:border-white">
                                <div className="absolute inset-0 bg-linear-to-t from-black/60 to-transparent opacity-40" />
                                <BookOpen className="w-12 h-12 text-primary/70 group-hover:scale-110 transition-transform duration-500" />
                            </div>

                            <div className="p-6 flex-1 flex flex-col">
                                <div className="mb-4 flex flex-wrap gap-2">
                                    {course.tags.slice(0, 3).map(tagSlug => {
                                        const tag = availableTags.find(t => t.slug === tagSlug);
                                        return tag ? (
                                            <span key={tagSlug} className="text-xs px-2 py-0.5 bg-primary/10 text-primary font-bold border border-black dark:border-white">
                                                {tag.name}
                                            </span>
                                        ) : null;
                                    })}
                                </div>

                                <h3 className="text-xl font-bold mb-2 group-hover:text-primary transition-colors">
                                    {course.title}
                                </h3>
                                <p className="text-muted-foreground text-sm line-clamp-3 mb-6 flex-1">
                                    {course.description || translations.no_courses}
                                </p>

                                <Link
                                    href={`/courses/${course.id}`}
                                    className="inline-flex items-center justify-center gap-2 w-full px-4 py-2 bg-primary text-primary-foreground text-sm font-bold border-2 border-black dark:border-white shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] dark:shadow-[4px_4px_0px_0px_rgba(255,255,255,1)] hover:translate-x-px hover:translate-y-px hover:shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] transition-all group/btn"
                                >
                                    {translations.start_course}
                                    <ArrowRight className="w-4 h-4 group-hover/btn:translate-x-1 transition-transform" />
                                </Link>
                            </div>
                        </motion.div>
                    ))}
                </AnimatePresence>

                {filteredCourses.length === 0 && (
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        className="col-span-full text-center py-20 bg-muted/10 border-2 border-dashed border-black dark:border-white"
                    >
                        <BookOpen className="w-12 h-12 text-muted-foreground mx-auto mb-4 opacity-50" />
                        <h3 className="text-xl font-medium">{translations.no_results}</h3>
                        <p className="text-muted-foreground mt-2">{translations.clear_filters}</p>
                    </motion.div>
                )}
            </div>
        </div>
    );
}
