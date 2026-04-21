import Navbar from '@/components/Navbar';
import Hero from '@/components/Hero';
import Features from '@/components/Features';
import HowItWorks from '@/components/HowItWorks';
import Technology from '@/components/Technology';
import Indicators from '@/components/Indicators';
import Stocks from '@/components/Stocks';
import News from '@/components/News';
import CTA from '@/components/CTA';
import Footer from '@/components/Footer';

export default function LandingPage() {
    return (
        <main>
            <Navbar />
            <Hero />
            <Features />
            <HowItWorks />
            <Technology />
            <Indicators />
            <Stocks />
            <News />
            <CTA />
            <Footer />
        </main>
    );
}
