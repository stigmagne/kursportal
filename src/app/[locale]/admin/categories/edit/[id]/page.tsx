'use client';

import CategoryForm from '@/components/admin/CategoryForm';
import { use } from 'react';

export default function EditCategoryPage({ params }: { params: Promise<{ id: string }> }) {
    const { id } = use(params);
    return <CategoryForm categoryId={id} />;
}
