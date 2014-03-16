# -*- coding: utf-8 -*-
require 'pi_piper'
require 'action_mailer'
require 'date'

## initial values
# initial light
value = 12
value_pre = 12
lightness_gap = 250

# stopping hours of start and end
starttime = 6
endtime = 9


ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  address: 'smtp.gmail.com',
  port: 587,
  domain: 'smtp.gmail.com',
  user_name: 'my_gmail_account',
  password: 'my_gmail_password',
  authentication: 'plain',
}

class Pi_mailer < ActionMailer::Base
  def sendmail(body)
#    attachment :content_type => "image/jpg",
#    :body =>  File.read("~osamu/ruby_projects/log/homephoto.jpg")
    attachments['homephoto.jpg'] = {
      :content => File.read('/home/osamu/ruby_projects/log/homephoto.jpg', :mode => 'rb'),
      :transfer_encoding => :binary
    }
    mail(
         to: 'to_mail_address',
         from: 'from_mail_address',
         subject: 'infro from Raspberry Pi',
         body: body.to_s
         )
    end
end

loop do
  PiPiper::Spi.begin do |spi|
    raw = spi.write [0b01101000,0]
    value_pre = value
    value = ((raw[0]<< 8) + raw[1]) & 0x03FF
    end

  day = Time.now
  # conditions of lightness gap and times
  if value-value_pre > lightness_gap and (day.hour < starttime or day.hour >endtime) then
    `raspistill -w 1024 -h 768 -t 1 -o ~osamu/ruby_projects/log/homephoto.jpg`
    Pi_mailer.sendmail("#{day}現在、玄関の明かりの値は#{value}です。").deliver
    end
  sleep(10)
end
