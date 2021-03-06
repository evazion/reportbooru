module Reports
  class TranslatorTags < Base
    def version
      1
    end

    def report_name
      "translator_tags"
    end

    def sort_key
      :total
    end

    def html_template
      return <<-EOS
%html
  %head
    %title Translator Tags Report
    %meta{:name => "viewport", :content => "width=device-width, initial-scale=1"}
    %script{:src => "/user-reports/assets/jquery-3.1.1.slim.min.js"}
    %script{:src => "/user-reports/assets/jquery.tablesorter.min.js"}
    %link{:rel => "stylesheet", :href => "/user-reports/assets/pure.css"}
    :javascript
      $(function() {
        $("#report").tablesorter();
      });
  %body
    %table{:id => "report", :class => "pure-table pure-table-bordered pure-table-striped"}
      %caption Translator Tags (over past thirty days, minimum uploads is #{min_changes})
      %thead
        %tr
          %th User
          %th Level
          %th Total
          %th +Total
          %th -Total
          %th{:title => "add translated"} +Trans
          %th{:title => "rem translated"} -Trans
          %th{:title => "add check_translation"} +Chk Trans
          %th{:title => "rem check_translation"} -Chk Trans
          %th{:title => "add partial_translation"} +Par Trans
          %th{:title => "rem partial_translation"} -Par Trans
          %th{:title => "add translation_request"} +Trans Req
          %th{:title => "rem translation_request"} -Trans Req
          %th{:title => "add commentary"} +Cmt
          %th{:title => "rem commentary"} -Cmt
          %th{:title => "add check_commentary"} +Chk Cmt
          %th{:title => "rem check_commentary"} -Chk Cmt
          %th{:title => "add commentary_request"} +Cmt Req
          %th{:title => "rem commentary_request"} -Cmt Req
      %tbody
        - data.each do |datum|
          %tr
            %td
              %a{:class => "user-\#{datum[:level]}", :href => "https://danbooru.donmai.us/users/\#{datum[:id]}"}= datum[:name]
            %td= datum[:level_string]
            %td= datum[:total]
            %td= datum[:add_total]
            %td= datum[:rem_total]
            %td= datum[:add_trans]
            %td= datum[:rem_trans]
            %td= datum[:add_check_trans]
            %td= datum[:rem_check_trans]
            %td= datum[:add_part_trans]
            %td= datum[:rem_part_trans]
            %td= datum[:add_trans_req]
            %td= datum[:rem_trans_req]
            %td= datum[:add_comment]
            %td= datum[:rem_comment]
            %td= datum[:add_check_comment]
            %td= datum[:rem_check_comment]
            %td= datum[:add_comment_req]
            %td= datum[:rem_comment_req]
    %p= "Since \#{date_window.utc} to \#{Time.now.utc}"
EOS
    end

    def calculate_data(user_id)
      user = DanbooruRo::User.find(user_id)
      client = BigQuery::PostVersion.new(date_window)

      h = {
        id: user.id,
        name: user.name,
        level: user.level,
        level_string: user.level_string,
        add_trans: client.count_tag_added(user_id, "translated"),
        rem_trans: client.count_tag_removed(user_id, "translated"),
        add_check_trans: client.count_tag_added(user_id, "check_translation"),
        rem_check_trans: client.count_tag_removed(user_id, "check_translation"),
        add_trans_req: client.count_tag_added(user_id, "translation_request"),
        rem_trans_req: client.count_tag_removed(user_id, "translation_request"),
        add_part_trans: client.count_tag_added(user_id, "partially_translated"),
        rem_part_trans: client.count_tag_removed(user_id, "partially_translated"),
        add_comment: client.count_tag_added(user_id, "commentary"),
        rem_comment: client.count_tag_removed(user_id, "commentary"),
        add_check_comment: client.count_tag_added(user_id, "check_commentary"),
        rem_check_comment: client.count_tag_removed(user_id, "check_commentary"),
        add_comment_req: client.count_tag_added(user_id, "commentary_request"),
        rem_comment_req: client.count_tag_removed(user_id, "commentary_request")
      }
      h[:add_total] = h[:add_trans].to_i + h[:add_check_trans].to_i + h[:add_part_trans].to_i + h[:add_comment].to_i + h[:add_check_comment].to_i + h[:add_comment_req].to_i
      h[:rem_total] = h[:rem_trans].to_i + h[:rem_check_trans].to_i + h[:rem_part_trans].to_i + h[:rem_comment].to_i + h[:rem_check_comment].to_i + h[:rem_comment_req].to_i
      h[:total] = h[:add_total] + h[:rem_total]
      h
    end

    def min_changes
      150
    end

    def candidates
      client = BigQuery::PostVersion.new(date_window)
      client.translator_tag_candidates(min_changes)
    end
  end
end
