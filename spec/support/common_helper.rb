# frozen_string_literal: true

module CommonHelper
  def next_id(klass)
    klass.maximum(:id).to_i.next
  end
end
