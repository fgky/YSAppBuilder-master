class QrController < ApplicationController
  def show
    @qr = RQRCode::QRCode.new(params[:id], :size => 4, :level => :h )
  end
end
