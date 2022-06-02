require "../spec_helper"

macro have_metadata(expected)
  %test_value = Spectator::Value.new({{expected}}, {{expected.stringify}})
  HaveMetadataMatcher.new(%test_value)
end

# No custom matcher DSL so far.
# https://gitlab.com/arctic-fox/spectator/-/issues/65
struct HaveMetadataMatcher < Spectator::Matchers::StandardMatcher
  def initialize(@expected : Spectator::Expression(Symbol), @args : Spectator::Mocks::Arguments? = nil)
  end

  def description : String
    "TODO"
  end

  private def match?(actual : Spectator::Expression(T)) : Bool forall T
    return false unless actual.value.metadata.has_key?(@expected.value)
    if @args
      args = to_arguments(actual.value.metadata[@expected.value])
      return false unless @args === args
    end
    true
  end

  private def failure_message(actual : Spectator::Expression(T)) : String forall T
    "TODO"
  end

  def with(*args, **opts)
    HaveMetadataMatcher.new(@expected, to_arguments(*args, **opts))
  end

  private def to_arguments(args : Tuple)
    to_arguments(*args)
  end

  private def to_arguments(*args, **opts)
    Spectator::Mocks::GenericArguments.new(args, opts)
  end
end

Spectator.describe Spectator::ContextHelper do
  # TODO: unknown how to get 'description'
  # let(:description) {  }

  # does not support shared_context yet
  # https://gitlab.com/arctic-fox/spectator/-/issues/73
  # shared_context :s1 do |value = 1|
  #   let(:v1) { value }
  # end

  # shared_context :s2 do |value = 2|
  #   let(:v2) { value }
  # end

  describe ".example_with" do
    example_with           {}
    example_with "message" {}
    example_with a: "1"    { expect(a).to eq "1" }

    example_with "message", a: -> { b }, b: "2", c: -> { -> {} } do
      expect(a).to eq "2"
      expect(b).to eq "2"
      expect(c).to be_an_instance_of Proc(Nil)
    end

    skip "description", reason: "unknown how to get 'description'" do
      example_with                                          { expect(description).to eq "" }
      example_with "message"                                { expect(description).to eq "message" }
      example_with _meta: :m1                               { expect(description).to eq "" }
      example_with _shared: :s1                             { expect(description).to eq "when s1" }
      example_with a: "1"                                   { expect(description).to eq %(when a is "1") }
      example_with a: "1", b: "2"                           { expect(description).to eq %(when a is "1" and b is "2") }
      example_with _meta: :m1, _shared: :s1, a: "1", b: "2" { expect(description).to eq %(when s1, a is "1" and b is "2") }
    end

    describe "metadata" do
      example_with _meta: :m1            { |e| expect(e).to have_metadata(:m1).with(nil) }
      example_with _meta: :m1            { |e| expect(e).not_to have_metadata(:m2) }
      example_with _meta: {:m1, :m2}     { |e| expect(e).to have_metadata(:m1).with(nil) }
      example_with _meta: {:m1, :m2}     { |e| expect(e).to have_metadata(:m2).with(nil) }
      example_with _meta: {:m1, {m2: 3}} { |e| expect(e).to have_metadata(:m1).with(nil) }
      example_with _meta: {:m1, {m2: 3}} { |e| expect(e).to have_metadata(:m2).with("3") }
    end

    skip "shared context", reason: "does not support shared_context yet" do
      example_with _shared: :s1            { expect(v1).to eq 1 }
      example_with _shared: :s1            { expect{ v2 }.to raise_error NameError }
      example_with _shared: {:s1, :s2}     { expect(v1).to eq 1 }
      example_with _shared: {:s1, :s2}     { expect(v2).to eq 2 }
      example_with _shared: {:s1, {s2: 3}} { expect(v1).to eq 1 }
      example_with _shared: {:s1, {s2: 3}} { expect(v2).to eq 3 }
    end
  end

  describe ".context_with" do
    context_with do
      example {}
    end

    context_with "message" do
      example {}
    end

    context_with a: "1" do
      example { expect(a).to eq "1" }
    end

    context_with "message", a: -> { b }, b: "2", c: -> { -> {} } do
      example { expect(a).to eq "2" }
      example { expect(b).to eq "2" }
      example { expect(c).to be_an_instance_of Proc(Nil) }
    end

    skip "description", reason: "unknown how to get 'description'" do
      context_with do
        example { expect(description).to eq "" }
      end

      context_with "message" do
        example { expect(description).to eq "message" }
      end

      context_with _meta: :m1 do
        example { expect(description).to eq "" }
      end

      context_with _shared: :s1 do
        example { expect(description).to eq "when s1" }
      end

      context_with a: "1" do
        example { expect(description).to eq %(when a is "1") }
      end

      context_with a: "1", b: "2" do
        example { expect(description).to eq %(when a is "1" and b is "2") }
      end

      context_with _meta: :m1, _shared: :s1, a: "1", b: "2" do
        example { expect(description).to eq %(when s1, a is "1" and b is "2") }
      end
    end

    describe "metadata" do
      context_with _meta: :m1 do
        example { |e| expect(e).to have_metadata(:m1).with(nil) }
        example { |e| expect(e).not_to have_metadata(:m2) }
      end

      context_with _meta: {:m1, :m2} do
        example { |e| expect(e).to have_metadata(:m1).with(nil) }
        example { |e| expect(e).to have_metadata(:m2).with(nil) }
      end

      context_with _meta: {:m1, {m2: 3}} do
        example { |e| expect(e).to have_metadata(:m1).with(nil) }
        example { |e| expect(e).to have_metadata(:m2).with("3") }
      end
    end

    skip "shared context", reason: "does not support shared_context yet" do
      context_with _shared: :s1 do
        example { expect(v1).to eq 1 }
        example { expect{ v2 }.to raise_error NameError }
      end

      context_with _shared: {:s1, :s2} do
        example { expect(v1).to eq 1 }
        example { expect(v2).to eq 2 }
      end

      context_with _shared: {:s1, {s2: 3}} do
        example { expect(v1).to eq 1 }
        example { expect(v2).to eq 3 }
      end
    end
  end
end
