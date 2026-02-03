'use client';

import { motion } from 'framer-motion';
import { ArrowRight, BookOpen, Shield, Lock, GraduationCap, LucideIcon } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { useTranslations } from 'next-intl';

export default function Home() {
  const t = useTranslations('Home');

  return (
    <div className="flex flex-col min-h-full bg-white">
      {/* Hero Section */}
      <section className="flex-1 flex flex-col items-center justify-center text-center px-4 sm:px-6 lg:px-8 py-20 relative overflow-hidden bg-secondary border-b-2 border-black">

        {/* Geometric Decor */}
        <div className="absolute inset-0 -z-10 opacity-10 pointer-events-none">
          <div className="absolute top-10 left-10 w-32 h-32 bg-primary border-2 border-black" />
          <div className="absolute bottom-20 right-20 w-48 h-48 rounded-full border-2 border-black bg-white" />
        </div>

        <div className="max-w-4xl mx-auto space-y-8 relative z-10">
          <div className="inline-flex items-center gap-2 px-4 py-2 bg-white border-2 border-black text-sm font-bold shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]">
            <span className="relative flex h-3 w-3">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
              <span className="relative inline-flex rounded-full h-3 w-3 bg-green-500 border border-black"></span>
            </span>
            {t('new_courses')}
          </div>

          <h1 className="text-5xl md:text-7xl font-extrabold tracking-tight text-black">
            {t('hero_title_1')} <span className="text-primary underline decoration-4 decoration-black underline-offset-4">{t('hero_title_highlight')}</span>.
            <br />
            {t('hero_title_2')} <span className="text-purple-600 underline decoration-4 decoration-black underline-offset-4">{t('hero_title_highlight_2')}</span>.
          </h1>

          <p className="text-xl text-gray-800 max-w-2xl mx-auto leading-relaxed font-medium">
            {t('hero_subtitle')}
          </p>

          <div className="flex flex-wrap items-center justify-center gap-4 pt-4">
            <Link href="/courses" className="px-8 py-4 bg-primary text-white font-bold text-lg hover:translate-y-1 transition-all flex items-center gap-2 border-2 border-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:shadow-none">
              {t('start_learning')} <ArrowRight className="w-5 h-5" />
            </Link>
            <Link href="/journal" className="px-8 py-4 bg-white text-black font-bold text-lg hover:bg-gray-50 hover:translate-y-1 transition-all border-2 border-black flex items-center gap-2 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:shadow-none">
              <Shield className="w-5 h-5" /> {t('private_journal')}
            </Link>
          </div>
        </div>
      </section>

      {/* Feature Grid */}
      <section className="py-24 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <FeatureCard
              icon={BookOpen}
              title={t('features.interactive_courses')}
              description={t('features.interactive_courses_desc')}
            />
            <FeatureCard
              icon={GraduationCap}
              title={t('features.smart_quizzes')}
              description={t('features.smart_quizzes_desc')}
            />
            <FeatureCard
              icon={Lock}
              title={t('features.zk_journal')}
              description={t('features.zk_journal_desc')}
            />
          </div>
        </div>
      </section>
    </div>
  );
}

function FeatureCard({ icon: Icon, title, description }: { icon: LucideIcon, title: string, description: string }) {
  return (
    <div className="p-8 bg-white border-2 border-black shadow-[6px_6px_0px_0px_rgba(0,0,0,1)] hover:translate-y-1 hover:shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] transition-all">
      <div className="w-12 h-12 bg-secondary border-2 border-black flex items-center justify-center text-black mb-6">
        <Icon className="w-6 h-6" />
      </div>
      <h3 className="text-xl font-bold mb-3 border-b-2 border-black pb-2 inline-block">{title}</h3>
      <p className="text-gray-600 leading-relaxed font-medium">{description}</p>
    </div>
  )
}
