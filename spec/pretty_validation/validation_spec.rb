require 'spec_helper'

module PrettyValidation
  describe Validation do
    describe '.sexy_validations' do
      context 'column is {null: false}' do
        include_context 'add_column', :name, :string, null: false, default: '', limit: 255
        subject { Validation.sexy_validations('users') }
        it { is_expected.to include build('validates', :name, presence: true, length: {maximum: 255}) }
      end

      context 'column type is nullable integer' do
        include_context 'add_column', :age, :integer
        subject { Validation.sexy_validations('users') }
        it { is_expected.to include build('validates', :age, numericality: true, allow_nil: true) }
      end

      context 'column type is not null integer' do
        include_context 'add_column', :login_count, :integer, null: true, default: 0
        subject { Validation.sexy_validations('users') }
        it { is_expected.to include build('validates', :login_count, numericality: true, allow_nil: true) }

        context 'column is ignored' do
          before{ allow(PrettyValidation.config).to receive(:ignored_columns).and_return(['users.login_count']) }
          it { is_expected.to be_empty }
        end
      end
    end

    describe '.unique_validations' do
      include_context 'add_column', :name, :string, null: false, default: ''
      include_context 'add_column', :age, :integer
      include_context 'add_column', :admin, :boolean
      include_context 'add_index', :name, unique: true
      include_context 'add_index', [:name, :age], unique: true
      include_context 'add_index', [:name, :age, :admin], unique: true
      subject { Validation.unique_validations('users') }

      it { is_expected.to include build('validates_uniqueness_of', :name) }
      it { is_expected.to include build('validates_uniqueness_of', :name, scope: :age, allow_nil: true) }
      it { is_expected.to include build('validates_uniqueness_of', :name, scope: [:age, :admin], allow_nil: true) }

      context 'uniqueness is ignored' do
        before{ allow(PrettyValidation.config).to receive(:ignored_uniqueness).and_return(['users.name_age_admin']) }
        it { expect(subject.length).to eq 2 }
      end
    end

    describe '#to_s' do
      context 'options is blank' do
        subject { build('validates_uniqueness_of', :name).to_s }
        it { is_expected.to eq 'validates_uniqueness_of :name' }
      end

      context 'options is present' do
        subject { build('validates_uniqueness_of', :name, scope: :age).to_s }
        it { is_expected.to eq 'validates_uniqueness_of :name, scope: :age' }
      end

      context 'options is multiple' do
        subject { build('validates', :age, presence: true, numericality: true).to_s }
        it { is_expected.to eq 'validates :age, presence: true, numericality: true' }
      end
    end
  end
end
