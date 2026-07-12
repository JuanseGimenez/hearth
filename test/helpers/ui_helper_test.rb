require "test_helper"

class UiHelperTest < ActionView::TestCase
  test "btn primary includes accent background and base classes" do
    result = btn(:primary)
    assert_includes result, "bg-amber-500"
    assert_includes result, "rounded-lg"
    assert_includes result, "cursor-pointer"
  end

  test "btn ghost is transparent" do
    assert_includes btn(:ghost), "bg-transparent"
  end

  test "btn danger uses red tokens" do
    assert_includes btn(:danger), "text-red-600"
  end

  test "btn small size overrides padding" do
    assert_includes btn(:primary, size: :small), "text-xs"
  end

  test "btn defaults to ghost" do
    assert_equal btn(:ghost), btn
  end

  test "btn primary has amber focus-visible ring" do
    assert_includes btn(:primary), "focus-visible:ring-amber-500/40"
  end

  test "input_class is full width bordered field" do
    assert_includes input_class, "w-full"
    assert_includes input_class, "rounded-lg"
  end

  test "input_class has amber focus-visible ring" do
    assert_includes input_class, "focus-visible:ring-amber-500/40"
  end

  test "label_class is uppercase muted" do
    assert_includes label_class, "uppercase"
    assert_includes label_class, "text-slate-500"
    assert_includes label_class, "dark:text-slate-400"
  end

  test "card_class has surface, border and radius" do
    assert_includes card_class, "rounded-2xl"
    assert_includes card_class, "shadow-sm"
  end

  test "checkbox_class uses amber accent" do
    assert_includes checkbox_class, "accent-amber-500"
  end

  test "color_input_class is a small swatch" do
    assert_includes color_input_class, "w-12"
  end

  test "color_input_class has amber focus-visible ring" do
    assert_includes color_input_class, "focus-visible:ring-amber-500/40"
  end

  test "badge_class on is green" do
    assert_includes badge_class(on: true), "text-green-600"
  end

  test "badge_class off is muted" do
    assert_includes badge_class, "text-slate-500"
  end
end
