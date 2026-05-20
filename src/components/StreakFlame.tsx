interface StreakFlameProps {
  streak: number;
  size?: "sm" | "md" | "lg";
}

export default function StreakFlame({ streak, size = "md" }: StreakFlameProps) {
  const dims = {
    sm: { wrap: "w-9 h-9", icon: "w-5 h-5", text: "text-xs" },
    md: { wrap: "w-12 h-12", icon: "w-6 h-6", text: "text-sm" },
    lg: { wrap: "w-16 h-16", icon: "w-8 h-8", text: "text-base" },
  }[size];

  const active = streak > 0;

  return (
    <div className="flex items-center gap-2.5">
      <div
        className={`${dims.wrap} rounded-full flex items-center justify-center ${
          active
            ? "bg-gradient-to-br from-orange-400 to-red-500 shadow-md shadow-orange-200"
            : "bg-navy/10"
        }`}
      >
        <svg
          className={`${dims.icon} ${active ? "text-white" : "text-navy/30"}`}
          viewBox="0 0 24 24"
          fill="currentColor"
        >
          <path d="M12.0001 23C7.0294 23 3.00012 18.9853 3.00012 14C3.00012 11.3837 4.04774 9.06587 5.92926 7.50045C6.43862 7.0773 7.18925 7.45633 7.18925 8.12222C7.18925 9.96022 8.34875 10.7411 9.30187 10.7411C10.5872 10.7411 11.6364 9.31766 11.0954 7.20889C10.5544 5.10012 11.1545 2.95611 12.4942 1.31544C12.7826 0.965147 13.3265 0.901524 13.6852 1.20489C16.4842 3.55322 18.0001 6.93733 18.0001 10.5C18.0001 10.7711 17.9923 11.0399 17.9772 11.3061C18.9633 11.0244 19.7858 10.3677 20.288 9.46667C20.5894 8.91933 21.3879 9.04644 21.5023 9.6731C21.8324 11.4444 22.0001 13.184 22.0001 14C22.0001 18.9853 16.9707 23 12.0001 23Z" />
        </svg>
      </div>
      <div className="flex flex-col leading-tight">
        <span className={`font-bold text-navy ${size === "lg" ? "text-2xl" : "text-lg"}`}>
          {streak}
        </span>
        <span className={`${dims.text} text-navy/50`}>day streak</span>
      </div>
    </div>
  );
}
