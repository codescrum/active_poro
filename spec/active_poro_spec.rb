require 'spec_helper'

describe 'ActivePoro' do
  context 'Model' do
    context 'relations' do

      context 'has_one + belongs_to' do
        before do
          class Driver < BaseTestClass
            include ActivePoro::Model
            has_one :car
          end

          class Car < BaseTestClass
            include ActivePoro::Model
            belongs_to :driver
          end
        end

        let(:driver){ Driver.new('Mike') }
        let(:car){ Car.new('A') }

        it 'initializes unrelated/unassociated' do
          expect(car.driver).to be_nil
          expect(driver.car).to be_nil
        end

        it 'associates the car to the driver and viceversa' do
          driver.car = car
          expect(car.driver).to eq(driver)
          expect(driver.car).to eq(car)
        end

        it 'associates the driver to the car and viceversa' do
          driver.car = car
          expect(driver.car).to eq(car)
          expect(car.driver).to eq(driver)
        end

      end

      context 'has_many + belongs_to' do
        before do
          class Dog < BaseTestClass
            include ActivePoro::Model
            has_many :fleas
          end

          class Flea < BaseTestClass
            include ActivePoro::Model
            belongs_to :dog
          end
        end

        let(:big_dog){ Dog.new('Big dog') }
        let(:flea_a){ Flea.new('A') }
        let(:flea_b){ Flea.new('B') }

        context 'when dog gets fleas' do
          let(:dog_with_fleas) do
            big_dog.fleas = [flea_a, flea_b]
            big_dog
          end

          it 'initializes with an empty array of fleas' do
            expect(big_dog.fleas).to eq([])
          end

          it 'is directly associated with pre-existant fleas' do
            expect(dog_with_fleas.fleas).to eq([flea_a, flea_b])
          end

          it 'correctly sets the right dog to each flea' do
            dog_with_fleas.fleas.each do |flea|
              expect(flea.dog).to eq(big_dog)
            end
          end
        end

        context 'when fleas jump onto big_dog' do
          it 'fleas have no dog to begin with' do
            expect(flea_a.dog).to be_nil
          end

          it 'fleas may have the big_dog associated to them and viceversa' do
            flea_a.dog = big_dog
            expect(flea_a.dog).to eq(big_dog)
            expect(big_dog.fleas).to eq([flea_a])

            flea_b.dog = big_dog
            expect(flea_b.dog).to eq(big_dog)
            expect(big_dog.fleas).to eq([flea_a, flea_b])
          end

        end

        context 'when a flea jumps between dogs' do

          let(:small_dog){ Dog.new('Small dog') }

          it 'cannot be in two dogs at the same time' do
            flea_a.dog = big_dog
            expect(flea_a.dog).to eq(big_dog)
            expect(big_dog.fleas).to eq([flea_a])

            # flea jumps from big dog to small dog
            flea_a.dog = small_dog
            expect(flea_a.dog).to eq(small_dog)
            expect(small_dog.fleas).to eq([flea_a])

            # flea A no longer in big dog
            expect(big_dog.fleas).to_not include(flea_a)
            expect(big_dog.fleas).to be_empty # sanity check
          end

        end
      end

    end
  end
end
