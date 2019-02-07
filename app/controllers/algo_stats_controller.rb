
class AlgoStatsController < ApplicationController

  require 'net/imap'

def show_statistics_algo
  @algo_stat = AlgoStat.last
  authorize @algo_stat
  @compute_solutions = ComputeSolution.last(50).select{|c| c.status != "pending"}.last(15)
  @table_rows = []
  @compute_solutions.each do |compute_solution|
    @table_rows << compute_solution.build_row_for_statistics_display
  end
  @bar_chart_rows = @algo_stat.calculations_per_week(@compute_solutions, "01/06/2018".to_date)
  @curve_chart_rows = curve_chart_rows
  @a = read_emails
end

def reload_statistics
  algo_stat = AlgoStat.create!
  authorize algo_stat
  UpdateAlgoStatsService.new().perform
  redirect_to statistics_algo_path
end

def read_emails
  a = []
  # connexion au server
  imap = Net::IMAP.new('mail.gandi.net')
  # login
  imap.login('hello@caplanpourmoi.org', 'Passworddelamort')
  # nombre de messages total de l'inbox
  number_messages = imap.status("inbox", ["UNSEEN"])["UNSEEN"]
  # Si messages non lus, se placer sur l'inbox, itérer sur chacun des emails reçus d'une adresse x
  unless number_messages.zero?
    imap.select('INBOX')
    imap.search(["FROM", "christelle.gaudron@gmail.com"]).each do |message_id|
      nb_PJ = 0
      # récupérer la structure du message
      envelope = imap.fetch(message_id, "ENVELOPE")[0].attr["ENVELOPE"]
      mail_structure = imap.fetch(message_id, 'RFC822')[0].attr['RFC822']
      mail = Mail.new(mail_structure)
      # si PJ
      unless mail.attachments.blank?
        # sauf si le fichier existe déjà (le rendre unique)
        unless File.exists?("public/attachments/#{mail.date}")
          # Dir.mkdir(File.join("public/attachments", "#{mail.message_id}"), 0700) # créer dossier
          # y stocker chacune des PJ
          mail.attachments.each do |attachment|
            File.open("public/attachments/#{mail.date}", 'wb') do |file|
            file.write(attachment.body.decoded)
            end
          end
          nb_PJ = 1
        end
        # placer dans /traité, supprimer de l'inbox
        imap.copy(message_id, 'Inbox/achieved')
        imap.store(message_id, "+FLAGS", [:Deleted])
        imap.expunge
      end
      # mettre en mémoire des attributs du mail
      a << "#{envelope.from[0].name}: - #{envelope.subject} - on: #{envelope.date} - #{nb_PJ} pièces jointes"
    end
  end # fin ce sur l'on fait si il y a des emails dans l'inbox
  imap.logout
  imap.disconnect
  [number_messages, a]
end

private

def curve_chart_rows
  # [[AlgoStat ID, tps moyen]]
  result = []
  AlgoStat.select{ |a| a.nb_fail != nil }.last(100).each do |a|
    result << [a.id, a.go_through_solutions_mean_time_per_slot]
  end
  result
end

end
