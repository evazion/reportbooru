class Post < DanbooruModel
  attr_readonly *column_names

  def self.raw_tag_match(tag)
    escaped_tag = "'#{tag.gsub(/\0/, '').gsub(/'/, '\0\0').gsub(/\\/, '\0\0\0\0')}'"
    where("tag_index @@ to_tsquery('danbooru', E?)", escaped_tag)
  end

  def self.partition(min_date, max_date)
    where("created_at between ? and ?", min_date, max_date).group("date_trunc('day', created_at)").select("date_trunc('day', created_at) as date, count(*) as post_count").order("date_trunc('day', created_at)")
  end

  def self.favorited_user_ids(post_id)
    fav_string = select_value_sql("select fav_string from posts where id = ?", post_id)
    user_ids = fav_string.scan(/\d+/)
  end
end