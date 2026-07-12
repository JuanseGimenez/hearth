module UiHelper
  BTN_BASE = "font-semibold rounded-lg border transition cursor-pointer".freeze

  BTN_SIZES = {
    normal: "text-sm px-3.5 py-2",
    small: "text-xs px-2.5 py-1.5"
  }.freeze

  BTN_VARIANTS = {
    primary: "bg-amber-500 hover:bg-amber-600 border-amber-500 hover:border-amber-600 text-amber-950",
    ghost: "bg-transparent border-slate-200 dark:border-zinc-700 text-slate-900 dark:text-zinc-100 hover:border-amber-500",
    danger: "bg-transparent text-red-600 border-red-600/30 hover:bg-red-500/10 hover:border-red-600"
  }.freeze

  def btn(variant = :ghost, size: :normal)
    "#{BTN_BASE} #{BTN_SIZES.fetch(size)} #{BTN_VARIANTS.fetch(variant)}"
  end

  def input_class
    "w-full px-2.5 py-2 border border-slate-200 dark:border-zinc-700 rounded-lg bg-white dark:bg-zinc-800 text-slate-900 dark:text-zinc-100"
  end

  def label_class
    "text-xs font-semibold uppercase tracking-wide text-slate-500"
  end

  def card_class
    "bg-white dark:bg-zinc-800 border border-slate-200 dark:border-zinc-700 rounded-2xl p-5 shadow-sm"
  end

  def checkbox_class
    "w-4 h-4 accent-amber-500"
  end

  def color_input_class
    "w-12 h-9 p-0.5 cursor-pointer border border-slate-200 dark:border-zinc-700 rounded-lg bg-white dark:bg-zinc-800"
  end

  def badge_class(on: false)
    base = "text-xs px-2 py-0.5 rounded-full font-semibold"
    tone = on ? "bg-green-500/15 text-green-600" : "bg-slate-100 dark:bg-zinc-800 text-slate-500"
    "#{base} #{tone}"
  end
end
