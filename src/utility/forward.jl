"""
    @forward Foo.bar f, g, h

`@forward` simply forwards method definition to a given field of a struct.
This is taken from ["MacroTools.jl"].
For example, the above is  equivalent to

```julia
f(x::Foo, args...) = f(x.bar, args...)
g(x::Foo, args...) = g(x.bar, args...)
h(x::Foo, args...) = h(x.bar, args...)
```
"""
macro forward(ex, fs)
  @capture(ex, T_.field_) || error("Syntax: @forward T.x f, g, h")
  T = esc(T)
  fs = isexpr(fs, :tuple) ? map(esc, fs.args) : [esc(fs)]
  :($([:($f(x::$T, args...) =
         (Base.@inline; $f(x.$field, args...)))
       for f in fs]...);
    nothing)
end

"""
    @forward2 Foo.bar f, g, h

`@forward2` forwards the first two positional arguments to a given field.
For example, the above is equivalent to

```julia
f(x::Foo, y::Foo, args...) = f(x.bar, y.bar, args...)
g(x::Foo, y::Foo, args...) = g(x.bar, y.bar, args...)
h(x::Foo, y::Foo, args...) = h(x.bar, y.bar, args...)
```

Note: the macro requires the second argument to be of the same container type as the
first (both are typed as the captured `T`).
"""
macro forward2(ex, fs)
  @capture(ex, T_.field_) || error("Syntax: @forward2 T.x f, g, h")
  T = esc(T)
  fs = isexpr(fs, :tuple) ? map(esc, fs.args) : [esc(fs)]
  :($([:($f(x::$T, y::$T, args...) =
         (Base.@inline; $f(x.$field, y.$field, args...)))
       for f in fs]...);
    nothing)
end

"""
    @forward_a_b Type.field f, g, ...

Generate methods that keep the first a args as-is and project the a+1,..,a+b args onto `field`.

Expands roughly to:

    f(x, y::Type, args...) = f(x, y.field, args...)
"""
macro forward_1_1(ex, fs)
  @capture(ex, T_.field_) || error("Syntax: @forward2 T.x f, g, h")
  T = esc(T)
  fs = isexpr(fs, :tuple) ? map(esc, fs.args) : [esc(fs)]
  :($([:($f(a,x::$T, args...) =
         (Base.@inline; $f(a, x.$field, args...)))
       for f in fs]...);
    nothing)
end

macro forward_2_1(ex, fs)
  @capture(ex, T_.field_) || error("Syntax: @forward2 T.x f, g, h")
  T = esc(T)
  fs = isexpr(fs, :tuple) ? map(esc, fs.args) : [esc(fs)]
  :($([:($f(a,b,x::$T, y::$T, args...) =
         (Base.@inline; $f(a, b, x.$field, y.$field, args...)))
       for f in fs]...);
    nothing)
end
macro forward_3_1(ex, fs)
  @capture(ex, T_.field_) || error("Syntax: @forward2 T.x f, g, h")
  T = esc(T)
  fs = isexpr(fs, :tuple) ? map(esc, fs.args) : [esc(fs)]
  :($([:($f(a,b,c,x::$T, y::$T, args...) =
         (Base.@inline; $f(a, b, c, x.$field, y.$field, args...)))
       for f in fs]...);
    nothing)
end
macro forward_3_1_astype(ex, fs)
  @capture(ex, T_.field_) || error("Syntax: @forward2 T.x f, g, h")
  T = esc(T)
  fs = isexpr(fs, :tuple) ? map(esc, fs.args) : [esc(fs)]
  :($([:($f(a,b,c,x::$T, y::$T, args...) =
         (Base.@inline; $T($f(a, b, c, x.$field, y.$field, args...))))
       for f in fs]...);
    nothing)
end
macro forward_astype(ex, fs)
  @capture(ex, T_.field_) || error("Syntax: @forward T.x f, g, h")
  T = esc(T)
  fs = isexpr(fs, :tuple) ? map(esc, fs.args) : [esc(fs)]
  :($([:($f(x::$T, args...) =
         (Base.@inline; $T($f(x.$field, args...))))
       for f in fs]...);
    nothing)
end