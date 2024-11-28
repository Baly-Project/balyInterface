class UpdateMailer < ApplicationMailer
  default from: "Automated Gallery Notifications <balydigitalgallery@gmail.com>"

  def update_email
    @logger=params[:log]
    mail(to: "singleton1@kenyon.edu", subject: "Update to Baly Gallery database")    
  end
end
