require 'test_helper'

class GovernmentTest < ActiveSupport::TestCase
  test "automatically adds a slug on creation" do
    government = FactoryGirl.create(:government, name: "2005 to 2010 Labour government")

    assert_equal "2005-to-2010-labour-government", government.slug
  end

  test "doesn't change the slug when the name changes" do
    government = FactoryGirl.create(:government, name: "2004 to 2009 Labour government")

    government.name = "2004 to 2009 Labour government"
    government.save!

    assert_equal "2004-to-2009-labour-government", government.slug
  end

  test "doesn't permit blank names" do
    blank_government = FactoryGirl.build(:government, name: '')
    nil_government = FactoryGirl.build(:government, name: nil)

    refute blank_government.valid?
    refute nil_government.valid?
  end

  test "doesn't permit blank start_date" do
    blank_government = FactoryGirl.build(:government, start_date: '')
    nil_government = FactoryGirl.build(:government, start_date: nil)

    refute blank_government.valid?
    refute nil_government.valid?
  end

  test "enforces unique names" do
    FactoryGirl.create(:government, name: "2005 to 2010 Labour government")
    duplicate_government = FactoryGirl.build(:government, name: "2005 to 2010 Labour government")

    refute duplicate_government.valid?
  end

  test "enforces unique slugs" do
    labour_government = FactoryGirl.create(:government, name: "2004 to 2009 Labour government")
    labour_government.name = "2005 to 2010 Labour government"
    labour_government.save!

    labour_government_duplicating_original_name = FactoryGirl.build(:government, name: "2004 to 2009 Labour government")

    refute labour_government_duplicating_original_name.valid?
  end

  test "knows the correct current government" do
    current_government = FactoryGirl.create(:government, name: "2010 to 2015 Conservative and Liberal democrat coalition government", start_date: '2010-05-12')
    previous_government = FactoryGirl.create(:government, name: "2005 to 2010 Labour government", start_date: '2005-05-06', end_date: '2010-05-11')

    assert_equal current_government, Government.current
  end

  test "knows the active government at a date" do
    government_current = FactoryGirl.create(:government, name: "2010 to 2015 Conservative and Liberal democrat coalition government", start_date: '2010-05-12')
    government_in_2005 = FactoryGirl.create(:government, name: "2005 to 2010 Labour government", start_date: '2005-05-06', end_date: '2010-05-11')
    FactoryGirl.create(:government, name: "2001 to 2005 Labour government", start_date: "2001-06-08", end_date: "2005-05-05")

    assert_equal government_in_2005, Government.on_date(Date.parse("2006-01-01")), "non-current government"
    assert_equal government_in_2005, Government.on_date(Date.parse("2010-05-11")), "last day of government"
    assert_equal government_current, Government.on_date(Date.parse("2010-05-12")), "first day of government"

    assert_nil Government.on_date(Date.parse("1900-05-12")), "non existant past government"
    assert_nil Government.on_date(Date.parse("2020-05-12")), "future date"
  end
end
