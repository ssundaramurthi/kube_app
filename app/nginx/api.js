
function return_version(r) {
    let val = {"version": "2.0.0","build_sha": "abc57858585","description" : "A sample API"}
    r.return(200, JSON.stringify(val));
}

export default {return_version};