class ChannelDebugController < ApplicationController
  allow_unauthenticated_access

  def show
    @boot_options = channel_boot_options
    @sdk_enabled = channel_sdk_enabled?
  end
end
