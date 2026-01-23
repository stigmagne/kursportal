'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import { useRouter } from 'next/navigation';
import { User, Mail, Calendar, Tag, Upload, Loader2, Save, Award, Activity } from 'lucide-react';
import { motion } from 'framer-motion';
import { useTranslations } from 'next-intl';
import { ActivityLog } from '@/components/profile/ActivityLog';
import { BadgeCollection } from '@/components/profile/BadgeCollection';

type Tab = 'overview' | 'badges' | 'activity';

export default function ProfilePage() {
    const t = useTranslations('Profile');
    const supabase = createClient();
    const router = useRouter();
    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);
    const [user, setUser] = useState<any>(null);
    const [profile, setProfile] = useState<any>(null);
    const [categories, setCategories] = useState<any[]>([]);
    const [isEditing, setIsEditing] = useState(false);
    const [activeTab, setActiveTab] = useState<Tab>('overview');

    const [formData, setFormData] = useState({
        full_name: '',
        bio: '',
    });

    useEffect(() => {
        fetchProfile();
    }, []);

    const fetchProfile = async () => {
        try {
            const { data: { user } } = await supabase.auth.getUser();
            if (!user) {
                router.push('/login');
                return;
            }
            setUser(user);

            const { data: profileData } = await supabase
                .from('profiles')
                .select('*')
                .eq('id', user.id)
                .single();

            setProfile(profileData);
            setFormData({
                full_name: profileData?.full_name || '',
                bio: profileData?.bio || '',
            });

            // Fetch user's assigned categories
            const { data: userCats } = await supabase
                .from('user_categories')
                .select('*, categories(*)')
                .eq('user_id', user.id);

            setCategories(userCats || []);
        } catch (error) {
            console.error('Error fetching profile:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleSave = async () => {
        setSaving(true);
        try {
            const { error } = await supabase
                .from('profiles')
                .update({
                    full_name: formData.full_name,
                    bio: formData.bio,
                })
                .eq('id', user.id);

            if (error) throw error;

            setProfile({ ...profile, ...formData });
            setIsEditing(false);
        } catch (error: any) {
            alert(t('alerts.update_error') + ': ' + error.message);
        } finally {
            setSaving(false);
        }
    };

    const handleAvatarUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        try {
            const fileExt = file.name.split('.').pop();
            const fileName = `${user.id}-${Date.now()}.${fileExt}`;
            const filePath = `avatars/${fileName}`;

            const { error: uploadError } = await supabase.storage
                .from('avatars')
                .upload(filePath, file);

            if (uploadError) throw uploadError;

            const { data: { publicUrl } } = supabase.storage
                .from('avatars')
                .getPublicUrl(filePath);

            const { error: updateError } = await supabase
                .from('profiles')
                .update({ avatar_url: publicUrl })
                .eq('id', user.id);

            if (updateError) throw updateError;

            setProfile({ ...profile, avatar_url: publicUrl });
        } catch (error: any) {
            alert(t('alerts.upload_error') + ': ' + error.message);
        }
    };

    if (loading) {
        return (
            <div className="min-h-screen flex items-center justify-center">
                <Loader2 className="w-8 h-8 animate-spin text-primary" />
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-background py-12">
            <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
                <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="space-y-8"
                >
                    {/* Header */}
                    <div>
                        <h1 className="text-3xl font-bold tracking-tight">{t('title')}</h1>
                        <p className="text-muted-foreground mt-2">{t('subtitle')}</p>
                    </div>

                    {/* Tabs */}
                    <div className="border-b border-gray-200">
                        <nav className="flex gap-8">
                            <button
                                onClick={() => setActiveTab('overview')}
                                className={`pb-4 px-1 border-b-2 font-medium text-sm transition-colors ${activeTab === 'overview'
                                    ? 'border-blue-500 text-blue-600'
                                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                                    }`}
                            >
                                <User className="w-4 h-4 inline mr-2" />
                                {t('overview')}
                            </button>
                            <button
                                onClick={() => setActiveTab('badges')}
                                className={`pb-4 px-1 border-b-2 font-medium text-sm transition-colors ${activeTab === 'badges'
                                    ? 'border-blue-500 text-blue-600'
                                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                                    }`}
                            >
                                <Award className="w-4 h-4 inline mr-2" />
                                {t('badges')}
                            </button>
                            <button
                                onClick={() => setActiveTab('activity')}
                                className={`pb-4 px-1 border-b-2 font-medium text-sm transition-colors ${activeTab === 'activity'
                                    ? 'border-blue-500 text-blue-600'
                                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                                    }`}
                            >
                                <Activity className="w-4 h-4 inline mr-2" />
                                {t('activity_log')}
                            </button>
                        </nav>
                    </div>

                    {/* Tab Content */}
                    {activeTab === 'overview' && (
                        <div className="space-y-8">
                            {/* Profile Card */}
                            <div className="bg-white rounded-2xl border border-gray-200 p-8">
                                <div className="flex flex-col md:flex-row gap-8">
                                    {/* Avatar Section */}
                                    <div className="flex flex-col items-center space-y-4">
                                        <div className="relative group">
                                            <div className="w-32 h-32 rounded-full overflow-hidden bg-gray-100 flex items-center justify-center border-4 border-blue-100">
                                                {profile?.avatar_url ? (
                                                    <img src={profile.avatar_url} alt="Avatar" className="w-full h-full object-cover" />
                                                ) : (
                                                    <User className="w-16 h-16 text-gray-400" />
                                                )}
                                            </div>
                                            <label className="absolute inset-0 flex items-center justify-center bg-black/60 rounded-full opacity-0 group-hover:opacity-100 transition-opacity cursor-pointer">
                                                <Upload className="w-6 h-6 text-white" />
                                                <input
                                                    type="file"
                                                    accept="image/*"
                                                    className="hidden"
                                                    onChange={handleAvatarUpload}
                                                />
                                            </label>
                                        </div>
                                        <p className="text-xs text-gray-500">{t('click_upload')}</p>
                                    </div>

                                    {/* Info Section */}
                                    <div className="flex-1 space-y-6">
                                        {isEditing ? (
                                            <>
                                                <div>
                                                    <label className="block text-sm font-medium mb-2 text-gray-700">{t('full_name')}</label>
                                                    <input
                                                        type="text"
                                                        value={formData.full_name}
                                                        onChange={(e) => setFormData({ ...formData, full_name: e.target.value })}
                                                        className="w-full px-4 py-2 rounded-lg bg-white border border-gray-300 focus:border-blue-500 focus:outline-none text-gray-900"
                                                    />
                                                </div>
                                                <div>
                                                    <label className="block text-sm font-medium mb-2 text-gray-700">{t('bio')}</label>
                                                    <textarea
                                                        value={formData.bio}
                                                        onChange={(e) => setFormData({ ...formData, bio: e.target.value })}
                                                        rows={4}
                                                        className="w-full px-4 py-2 rounded-lg bg-white border border-gray-300 focus:border-blue-500 focus:outline-none resize-none text-gray-900"
                                                        placeholder={t('bio_placeholder')}
                                                    />
                                                </div>
                                                <div className="flex gap-3">
                                                    <button
                                                        onClick={handleSave}
                                                        disabled={saving}
                                                        className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg font-medium hover:bg-blue-700 transition-colors disabled:opacity-50"
                                                    >
                                                        {saving ? <Loader2 className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />}
                                                        {t('save_changes')}
                                                    </button>
                                                    <button
                                                        onClick={() => setIsEditing(false)}
                                                        className="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg font-medium hover:bg-gray-300 transition-colors"
                                                    >
                                                        {t('cancel')}
                                                    </button>
                                                </div>
                                            </>
                                        ) : (
                                            <>
                                                <div>
                                                    <h2 className="text-2xl font-bold text-gray-900">{profile?.full_name || t('no_name')}</h2>
                                                    <p className="text-gray-600 mt-1">{profile?.bio || t('no_bio')}</p>
                                                </div>

                                                <div className="space-y-3">
                                                    <div className="flex items-center gap-3 text-sm text-gray-700">
                                                        <Mail className="w-4 h-4 text-gray-400" />
                                                        <span>{user?.email}</span>
                                                    </div>
                                                    <div className="flex items-center gap-3 text-sm text-gray-700">
                                                        <Calendar className="w-4 h-4 text-gray-400" />
                                                        <span>{t('joined')} {new Date(profile?.created_at).toLocaleDateString()}</span>
                                                    </div>
                                                    <div className="flex items-center gap-3 text-sm text-gray-700">
                                                        <User className="w-4 h-4 text-gray-400" />
                                                        <span className="capitalize">{profile?.role}</span>
                                                    </div>
                                                </div>

                                                <button
                                                    onClick={() => setIsEditing(true)}
                                                    className="px-4 py-2 bg-blue-600 text-white rounded-lg font-medium hover:bg-blue-700 transition-colors"
                                                >
                                                    {t('edit_profile')}
                                                </button>
                                            </>
                                        )}
                                    </div>
                                </div>
                            </div>

                            {/* Assigned Categories */}
                            {categories.length > 0 && (
                                <div className="bg-white rounded-2xl border border-gray-200 p-8">
                                    <h3 className="text-xl font-semibold mb-4 flex items-center gap-2 text-gray-900">
                                        <Tag className="w-5 h-5 text-blue-500" />
                                        {t('categories')}
                                    </h3>
                                    <div className="flex flex-wrap gap-2">
                                        {categories.map((uc: any) => (
                                            <span
                                                key={uc.category_id}
                                                className="px-3 py-1 rounded-full text-sm font-medium border"
                                                style={{
                                                    backgroundColor: `${uc.categories.color}20`,
                                                    borderColor: uc.categories.color,
                                                    color: uc.categories.color,
                                                }}
                                            >
                                                {uc.categories.name}
                                            </span>
                                        ))}
                                    </div>
                                    <p className="text-xs text-gray-500 mt-4">
                                        {t('categories_desc')}
                                    </p>
                                </div>
                            )}
                        </div>
                    )}

                    {activeTab === 'badges' && (
                        <div className="bg-white rounded-2xl border border-gray-200 p-8">
                            <BadgeCollection />
                        </div>
                    )}

                    {activeTab === 'activity' && (
                        <div className="bg-white rounded-2xl border border-gray-200 p-8">
                            <h3 className="text-xl font-semibold mb-6 text-gray-900">{t('activity_log')}</h3>
                            <ActivityLog />
                        </div>
                    )}
                </motion.div>
            </div>
        </div>
    );
}
