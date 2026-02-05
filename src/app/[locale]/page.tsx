'use client';

import { useState } from 'react';
import { ArrowRight, BookOpen, Shield, Target, Users, X, ExternalLink } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { useTranslations } from 'next-intl';

export default function Home() {
  const t = useTranslations('Home');
  const [showZkModal, setShowZkModal] = useState(false);

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
            <Users className="w-4 h-4" />
            {t('badge')}
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
            <Link href="/login" className="px-8 py-4 bg-primary text-primary-foreground font-bold text-lg hover:translate-y-1 transition-all flex items-center gap-2 border-2 border-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:shadow-none">
              {t('sign_in')} <ArrowRight className="w-5 h-5" />
            </Link>
            <Link href="#features" className="px-8 py-4 bg-white text-black font-bold text-lg hover:bg-gray-50 hover:translate-y-1 transition-all border-2 border-black flex items-center gap-2 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:shadow-none">
              {t('learn_more')}
            </Link>
          </div>
        </div>
      </section>

      {/* Feature Grid */}
      <section id="features" className="py-24 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <FeatureCard
              icon={BookOpen}
              title={t('features.courses_tools')}
              description={t('features.courses_tools_desc')}
            />
            <FeatureCard
              icon={Target}
              title={t('features.self_assessment')}
              description={t('features.self_assessment_desc')}
            />
            <div className="p-8 bg-white border-2 border-black shadow-[6px_6px_0px_0px_rgba(0,0,0,1)] hover:translate-y-1 hover:shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] transition-all">
              <div className="w-12 h-12 bg-secondary border-2 border-black flex items-center justify-center text-black mb-6">
                <Shield className="w-6 h-6" />
              </div>
              <h3 className="text-xl font-bold mb-3 border-b-2 border-black pb-2 inline-block">{t('features.zk_journal')}</h3>
              <p className="text-gray-600 leading-relaxed font-medium mb-4">{t('features.zk_journal_desc')}</p>
              <button
                onClick={() => setShowZkModal(true)}
                className="text-primary font-bold text-sm hover:underline flex items-center gap-1"
              >
                {t('features.zk_what_is')} <ExternalLink className="w-3 h-3" />
              </button>
            </div>
          </div>
        </div>
      </section>

      {/* Zero-Knowledge Modal */}
      {showZkModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4" onClick={() => setShowZkModal(false)}>
          <div
            className="bg-white border-2 border-black shadow-[8px_8px_0px_0px_rgba(0,0,0,1)] max-w-lg w-full p-8 relative"
            onClick={e => e.stopPropagation()}
          >
            <button
              onClick={() => setShowZkModal(false)}
              className="absolute top-4 right-4 p-1 hover:bg-gray-100"
            >
              <X className="w-5 h-5" />
            </button>
            <div className="flex items-center gap-3 mb-4">
              <div className="w-10 h-10 bg-primary border-2 border-black flex items-center justify-center">
                <Shield className="w-5 h-5 text-white" />
              </div>
              <h2 className="text-2xl font-bold">Zero-Knowledge</h2>
            </div>
            <p className="text-gray-700 leading-relaxed mb-6">
              {t('features.zk_explanation')}
            </p>
            <a
              href="https://en.wikipedia.org/wiki/End-to-end_encryption"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2 text-primary font-bold hover:underline"
            >
              {t('features.zk_read_more')} <ExternalLink className="w-4 h-4" />
            </a>
          </div>
        </div>
      )}
    </div>
  );
}

function FeatureCard({ icon: Icon, title, description }: { icon: typeof BookOpen, title: string, description: string }) {
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
