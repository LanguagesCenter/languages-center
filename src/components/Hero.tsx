export default function Hero() {
  return (
    <section className="relative pt-20 pb-16 px-4 text-center overflow-hidden">
      {/* Subtle peach gradient background */}
      <div className="absolute inset-0 bg-gradient-to-b from-peach/40 via-peach-light/30 to-transparent pointer-events-none" />

      <div className="relative">
        <h1 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold text-navy tracking-tight max-w-3xl mx-auto leading-[1.1]">
          Learn any language,{" "}
          <span className="text-teal">anywhere</span>
        </h1>
        <p className="mt-6 text-lg text-navy/60 max-w-2xl mx-auto leading-relaxed">
          Explore languages from around the world. Find the right language for you,
          understand difficulty levels, and start your journey today.
        </p>
      </div>
    </section>
  );
}
