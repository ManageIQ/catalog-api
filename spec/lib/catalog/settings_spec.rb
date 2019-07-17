describe Catalog::Settings do
  context "when loading without a namespace specified" do
    it "loads the default namespace" do
      settings = described_class.new

      expect(settings.values.keys).to match_array %w[default_workflow]
      expect(settings.default_workflow).to eq '-1'
    end
  end

  context "when specifying a namespace" do
    let(:settings) { described_class.new("icons") }

    it "loads the namespace specified" do
      expect(settings.values.keys).to match_array %w[ansible openshift]
    end

    it "creates the appropriate methods" do
      expect(settings.ansible).to eq '<svg xmlns="http://www.w3.org/2000/svg" viewBox="-97.62 -147.24 64 64" d="M-33.62-115.24c0 17.674-14.326 32-32 32s-32-14.326-32-32 14.328-32 32-32 32 14.328 32 32" fill="#1a1918"/><path d="M-65.08-127.692l8.28 20.438-12.508-9.853zm14.7 25.147L-63.108-133.2c-.364-.884-1.1-1.352-1.973-1.352s-1.664.468-2.028 1.352L-81.1-99.576h4.783l5.534-13.863 16.515 13.343c.664.537 1.144.78 1.767.78 1.248 0 2.338-.936 2.338-2.286 0-.22-.078-.57-.218-.944z" fill="#fff"/></svg>'

      expect(settings.openshift).to eq '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 60 60"><g fill="#db212f"><path d="M17.424 27.158L7.8 30.664c.123 1.545.4 3.07.764 4.566l9.15-3.333c-.297-1.547-.403-3.142-.28-4.74M60 16.504c-.672-1.386-1.45-2.726-2.35-3.988l-9.632 3.506c1.12 1.147 2.06 2.435 2.83 3.813z"/><path d="M38.802 13.776c2.004.935 3.74 2.21 5.204 3.707l9.633-3.506a27.38 27.38 0 0 0-10.756-8.95c-13.77-6.42-30.198-.442-36.62 13.326a27.38 27.38 0 0 0-2.488 13.771l9.634-3.505c.16-2.087.67-4.18 1.603-6.184 4.173-8.947 14.844-12.83 23.79-8.658"/></g><path d="M9.153 35.01L0 38.342c.84 3.337 2.3 6.508 4.304 9.33l9.612-3.5a17.99 17.99 0 0 1-4.763-9.164" fill="#ea2227"/><path d="M49.074 31.38a17.64 17.64 0 0 1-1.616 6.186c-4.173 8.947-14.843 12.83-23.79 8.657a17.71 17.71 0 0 1-5.215-3.7l-9.612 3.5c2.662 3.744 6.293 6.874 10.748 8.953 13.77 6.42 30.196.44 36.618-13.328a27.28 27.28 0 0 0 2.479-13.765l-9.61 3.498z" fill="#db212f"/><path d="M51.445 19.618l-9.153 3.332c1.7 3.046 2.503 6.553 2.24 10.08l9.612-3.497c-.275-3.45-1.195-6.817-2.7-9.915" fill="#ea2227"/></svg>'
    end
  end

  context "when loading from a custom config file" do
    let(:filename) { "spec/support/test_settings.yml" }

    context "when not specifying a namespace" do
      it "loads the default namespace" do
        settings = described_class.new(nil, filename)

        expect(settings.values.keys).to match_array %w[a_setting]
        expect(settings.a_setting).to eq "a value"
      end
    end

    context "when specifying a namespace" do
      it "loads the specified namespace" do
        settings = described_class.new("my_namespace", filename)

        expect(settings.values.keys).to match_array %w[another_setting]
        expect(settings.another_setting).to eq "another value"
      end
    end
  end
end
