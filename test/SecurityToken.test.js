const SecurityTokenAbstraction = artifacts.require('SecurityToken');

contract('SecurityToken', function(accounts) {
  let SC;
  const owner = accounts[0];
  const controller = accounts[1];

  beforeEach( async () => {
    SC = await SecurityTokenAbstraction.new(controller, web3.utils.asciiToHex('SC'));
  });

  describe('controller', () => {
    it('it sets the controller', async () => {
      const foundController = await SC.controller();
      expect(foundController).to.be.equal(controller);
    });
  });
});
