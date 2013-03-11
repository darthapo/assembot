# it 'should ', ->

{Resource, ResourceList, resourcelist}= require '../lib/resources'
{expect}= chai= require 'chai'
should= chai.should()

###
>>> Resource
###
describe 'Resource class', ->

  beforeEach ->
    @res=new Resource 'app/test.js', "TEST"
    should.exist @res

  it 'should exist', ->
    should.exist Resource

  it 'should allow construction with filename and content', ->
    @res.should.have.property 'content', "TEST"

  it 'should allow construction with filename only', ->
    res= new Resource 'app/test.coffee'
    res.should.exist
    res.should.not.have.property 'content'

  it 'should set the target based on the filename', ->
    @res.should.have.property 'target', 'js'
    res= new Resource 'app/test.coffee'
    res.should.have.property 'target', 'js'

  it 'should extract the extension', ->
    @res.should.have.property 'ext', '.js'

  it 'should set the module path', ->
    @res.should.have.property 'path', 'app/test'

  it 'should set the file type', ->
    @res.should.have.property 'type', 'js'
    res= new Resource 'app/test.coffee'
    res.should.have.property 'type', 'coffee'




###
>>> ResourceList
###
describe 'ResourceList class', ->

  it 'should exist', ->
    should.exist ResourceList

  it 'should allow creation with empty args', ->
    reslist= new ResourceList
    should.exist reslist
    reslist.should.have.property 'length', 0
    # Internals test... Yikes!
    reslist.should.have.property 'list'

  it 'should allow creation from filepath', ->
    reslist= ResourceList.fromPath './test/fixtures'
    should.exist reslist
    reslist.should.have.property 'length', 4

  it 'should allow filtering by type', ->
    reslist= ResourceList.fromPath './test/fixtures'
    jslist= reslist.forTarget('js')
    should.exist jslist
    jslist.should.have.length 2

    csslist= reslist.forTarget('css')
    should.exist csslist
    csslist.should.have.length 2

    xlist= reslist.forTarget('unknown')
    should.exist xlist
    xlist.should.have.length 0


    


###
>>> HELPERS
###
describe 'resourcelist helper method', ->

  it 'should exist', ->
    should.exist resourcelist

  it 'should return a populated ResourceList from path', ->
    reslist= resourcelist './test/fixtures'
    jslist= reslist.forTarget('js')
    should.exist jslist
    jslist.should.have.length 2

    csslist= reslist.forTarget('css')
    should.exist csslist
    csslist.should.have.length 2

    xlist= reslist.forTarget('unknown')
    should.exist xlist
    xlist.should.have.length 0
