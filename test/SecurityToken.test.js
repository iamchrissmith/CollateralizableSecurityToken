const SecurityTokenAbstraction = artifacts.require('SecurityToken');

contract('SecurityToken', function(accounts) {
    let SC;
    const owner = accounts[0];
    const controller = accounts[1];

    beforeEach( async () => {
        SC = await SecurityTokenAbstraction.new();
    });

    describe('contoller', () => {
        it('it sets the controller')
    })
}
