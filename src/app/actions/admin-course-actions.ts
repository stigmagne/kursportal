'use server';

import { createClient } from '@/utils/supabase/server';
import { revalidatePath } from 'next/cache';

interface ImportCourseData {
    title: string;
    description: string;
    content: string;
    tags: string[];
    modules: {
        title: string;
        description: string;
        lessons: {
            title: string;
            description: string;
            content: string;
            duration_minutes: number;
        }[];
    }[];
}

export async function importCourse(jsonData: string) {
    try {
        const supabase = await createClient();

        // Check authentication
        const { data: { user }, error: authError } = await supabase.auth.getUser();
        if (authError || !user) throw new Error('Unauthorized');

        // Check admin role
        const { data: profile } = await supabase
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .single();

        if (profile?.role !== 'admin') {
            throw new Error('Only admins can import courses');
        }

        // Parse JSON
        let courseData: ImportCourseData;
        try {
            courseData = JSON.parse(jsonData);
        } catch (e) {
            throw new Error('Invalid JSON format');
        }

        // Validate structure (basic check)
        if (!courseData.title || !Array.isArray(courseData.modules)) {
            throw new Error('Invalid course structure: Missing title or modules array');
        }

        // Use Admin client for complex transaction-like operations to ensure no RLS hiccups, 
        // although standard client should work for admins. 
        // Let's use the standard client we have as it has the user context for 'created_by' / 'author_id'.
        // Actually, schema.sql says author_id references profiles.

        // 1. Create Course
        const { data: course, error: courseError } = await supabase
            .from('courses')
            .insert({
                title: courseData.title,
                description: courseData.description || '',
                content: courseData.content || '',
                author_id: user.id,
                published: false // Draft by default
            })
            .select()
            .single();

        if (courseError) throw new Error('Failed to create course: ' + courseError.message);

        const courseId = course.id;

        // 2. Handle Tags
        if (courseData.tags && courseData.tags.length > 0) {
            for (const tagName of courseData.tags) {
                // Ensure tag exists
                // We use upsert or select-first logic. 
                // Since 'name' is usually unique in tags table (hopefully).
                // Let's check tags table schema assumption: likely id, name.

                // First try to find existing tag
                const { data: existingTag } = await supabase
                    .from('tags')
                    .select('id')
                    .ilike('name', tagName)
                    .single(); // ilike for case-insensitive match

                let tagId = existingTag?.id;

                if (!tagId) {
                    // Create new tag
                    const { data: newTag, error: tagError } = await supabase
                        .from('tags')
                        .insert({ name: tagName })
                        .select('id')
                        .single();

                    if (!tagError && newTag) {
                        tagId = newTag.id;
                    }
                }

                // Link tag to course
                if (tagId) {
                    await supabase
                        .from('course_tags')
                        .insert({
                            course_id: courseId,
                            tag_id: tagId
                        });
                }
            }
        }

        // 3. Create Modules and Lessons
        // We'll process modules sequentially to maintain order
        let moduleOrder = 0;
        for (const mod of courseData.modules) {
            const { data: moduleData, error: moduleError } = await supabase
                .from('course_modules')
                .insert({
                    course_id: courseId,
                    title: mod.title,
                    order_index: moduleOrder++,
                    // description might not be in schema, let's skip or check later. 
                    // ModuleManager interface showed description: string | null. So we include it.
                    description: mod.description || ''
                })
                .select()
                .single();

            if (moduleError) {
                console.error('Failed to create module', mod.title, moduleError);
                continue; // Skip this module on error
            }

            // Create Lessons
            if (mod.lessons && mod.lessons.length > 0) {
                let lessonOrder = 0;
                const lessonsToInsert = mod.lessons.map(lesson => ({
                    module_id: moduleData.id,
                    title: lesson.title,
                    // description: lesson.description, // Lesson interface has description? Yes.
                    order_index: lessonOrder++,
                    content: lesson.content || '',
                    duration_minutes: lesson.duration_minutes || 0
                }));

                // Batch insert lessons for this module
                const { error: lessonsError } = await supabase
                    .from('lessons')
                    .insert(lessonsToInsert);

                if (lessonsError) {
                    console.error('Failed to insert lessons for module', mod.title, lessonsError);
                }
            }
        }

        revalidatePath('/admin/courses');
        return { success: true, courseId };

    } catch (error: any) {
        console.error('Import error:', error);
        return { success: false, error: error.message };
    }
}
