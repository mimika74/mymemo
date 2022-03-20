class InquiryMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.inquiry_mailer.inquiry_mail.subject
  #
  def inquiry_mail(inquiry)
    #@greeting = "Hi"
    #mail to: "to@example.org"
    @inquiry = inquiry
    mail(
      from: ENV['SEND_MAIL'],
      to: inquiry.email,
      subject: "お問い合わせを承りました。",
      bcc: ENV['SEND_MAIL'],
    )
  end
end
