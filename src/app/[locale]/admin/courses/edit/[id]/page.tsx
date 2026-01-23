'use client';

import CourseEditor from '@/components/admin/CourseEditor';
import { use } from 'react';

export default function EditCoursePage({ params }: { params: Promise<{ id: string }> }) {
    const { id } = use(params);
    return <CourseEditor courseId={id} />;
}
