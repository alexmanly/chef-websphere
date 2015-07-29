require 'spec_helper'

describe port(28000) do
  it { should be_listening }
end

describe port(28001) do
  it { should be_listening }
end
