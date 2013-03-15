_= require '../lib/util'
{expect}= chai= require 'chai'
should= chai.should()

###
>>> Util
###
describe 'Util helpers', ->

  it 'should exist', ->
    should.exist _

  describe 'defaults()', ->

    it 'should add only missing fields', ->
      o=
        name: 'Matt'
      od= _.defaults o, { name:'Dan', age:'old' }
      od.should.have.property 'name', 'Matt'
      od.should.have.property 'age', 'old'