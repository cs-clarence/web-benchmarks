type BigIntToJSON = { prototype: { toJSON: () => string } };

if (!(BigInt as unknown as BigIntToJSON).prototype.toJSON) {
    (BigInt as unknown as BigIntToJSON).prototype.toJSON = function () {
        return this.toString();
    };
}
