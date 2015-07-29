control_group "WebSphere Audit" do
  
  control 'Websphere' do
    it 'should be listening on port 28000' do
      expect(port(28000)).to be_listening
    end

    it 'should be listening on port 28001' do
      expect(port(28001)).to be_listening
    end

    # it "/opt/IBM should be mounted with an ext4 partition" do
    #   expect(file("/opt/IBM")).to be_mounted.with( :type => "ext4" )
    # end
  end
end