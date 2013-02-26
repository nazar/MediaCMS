class RenameJournalType < ActiveRecord::Migration
  def self.up
    rename_column(:journals, :type, :journal_type)
    remove_column(:postings, :debit_credit)
  end

  def self.down
    rename_column(:journals, :journal_type, :type)
    add_column(:postings, :debit_credit, :boolean, {:default => 0})
  end
end
