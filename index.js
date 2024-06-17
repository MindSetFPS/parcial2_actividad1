function replacer(key, value) {
    // Filtering out properties

    var removedProperties = ["myobject", "week", "model", "transport", "month"]
    if (removedProperties.includes(key)) {
        return undefined;
    } else {
        console.log(key)
        return value
    }
}

const foo = {
    foundation: "Mozilla",
    model: "box",
    week: 45,
    myobject: {
        ola: 1,
        hello: "hello"
    },
    transport: "car",
    month: 7,
};
console.log(JSON.stringify(foo, replacer))
// '{"week":45,"month":7}'

console.log(foo instanceof Object)