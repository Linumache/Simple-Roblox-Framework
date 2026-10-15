--[=[
    @class RingBuffer
]=]

local Types = require("../Types")

type RingBuffer<T> = Types.RingBuffer<T>

local RingBuffer = {}
RingBuffer.__index = RingBuffer

local MAX_SIZE = 2 ^ 26

--[=[
    @within RingBuffer
    @param MaxSize number
    @return RingBuffer<T>
]=]
--[=[
    @within RingBuffer
    @prop _Buffer { T }
    @private
]=]
--[=[
    @within RingBuffer
    @prop _Count number
    @private
]=]
--[=[
    @within RingBuffer
    @prop _Head number
    @private
]=]
--[=[
    @within RingBuffer
    @prop _MaxSize number
    @private
]=]
--[=[
    @within RingBuffer
    @prop _Tail number
    @private
]=]
function RingBuffer.new<T>(MaxSize: number)
    local self = setmetatable({
        _Buffer = table.create(MaxSize) :: { T },
        _Count = 0,
        _Head = 1,
        _MaxSize = math.clamp(MaxSize, 1, MAX_SIZE),
        _Tail = 1,
    }, RingBuffer) :: RingBuffer<T>
    return self
end

--[=[
    @method Push
    @within RingBuffer
    @param Value T
]=]
function RingBuffer.Push<T>(self: RingBuffer<T>, Value: T)
    local Count = self._Count
    local Head = self._Head
    local MaxSize = self._MaxSize

    self._Buffer[Head] = Value
    self._Head = if Head < MaxSize then Head + 1 else 1

    if Count == MaxSize then
        local Tail = self._Tail
        self._Tail = if Tail < MaxSize then Tail + 1 else 1
    else
        self._Count = Count + 1
    end
end

--[=[
    @method Pop
    @within RingBuffer
    @return T?
]=]
function RingBuffer.Pop<T>(self: RingBuffer<T>): T?
    local Count = self._Count
    if Count == 0 then return nil end

    local Tail = self._Tail
    local Value = self._Buffer[Tail]

    if Value ~= nil then
        self._Buffer[Tail] = nil
        self._Count = Count - 1
        self._Tail = if Tail < self._MaxSize then Tail + 1 else 1
    end

    return Value
end

--[=[
    @method PopTail
    @within RingBuffer
    @return T?
]=]
function RingBuffer.PopTail<T>(self: RingBuffer<T>): T?
    local Count = self._Count
    if Count == 0 then return nil end

    local Head = self._Head
    local Value = self._Buffer[Head]

    if Value ~= nil then
        self._Buffer[Head] = nil
        self._Head = if Head == 1 then self._MaxSize else Head - 1
        self._Count = Count - 1
    end

    return Value
end

--[=[
    @method Peek
    @within RingBuffer
    @return T?
]=]
function RingBuffer.Peek<T>(self: RingBuffer<T>): T? return self._Buffer[self._Tail] end

--[=[
    @method PeekHead
    @within RingBuffer
    @return T?
]=]
function RingBuffer.PeekHead<T>(self: RingBuffer<T>): T?
    if self._Count == 0 then return nil end

    local LastIndex = self._Head - 1
    if LastIndex < 1 then return self._Buffer[self._MaxSize] end

    return self._Buffer[LastIndex]
end

--[=[
    @method At
    @within RingBuffer
    @param Index number
    @return T?
]=]
function RingBuffer.At<T>(self: RingBuffer<T>, Index: number): T?
    if self._Count == 0 then return nil end

    local Cursor = self._Tail + Index
    local MaxSize = self._MaxSize
    if Cursor > MaxSize then return self._Buffer[Cursor - MaxSize] end

    return self._Buffer[Cursor]
end

--[=[
    @method AtHead
    @within RingBuffer
    @param Index number
    @return T?
]=]
function RingBuffer.AtHead<T>(self: RingBuffer<T>, Index: number): T?
    if self._Count == 0 then return nil end

    local Cursor = self._Head - Index
    if Cursor < 1 then return self._Buffer[self._MaxSize] end

    return self._Buffer[Cursor]
end

--[=[
    @method SetMaxSize
    @within RingBuffer
    @param NewMaxSize number
]=]
function RingBuffer.SetMaxSize<T>(self: RingBuffer<T>, NewMaxSize: number)
    NewMaxSize = math.clamp(NewMaxSize, 1, MAX_SIZE)
    if self._MaxSize == NewMaxSize then return end

    local OldCount = self._Count

    local FinalCount = math.min(OldCount, NewMaxSize)
    local NewBuffer = table.create(NewMaxSize)

    if FinalCount > 0 then
        local OldMaxSize = self._MaxSize
        local OldBuffer = self._Buffer

        local PhysicalStart
        if OldCount > NewMaxSize then
            PhysicalStart = self._Head - FinalCount
            if PhysicalStart < 1 then
                PhysicalStart += OldMaxSize
            end
        else
            PhysicalStart = self._Tail
        end

        local PhysicalEnd = PhysicalStart + FinalCount - 1
        if PhysicalEnd > OldMaxSize then
            local FirstPartLength = OldMaxSize - PhysicalStart + 1
            table.move(OldBuffer, PhysicalStart, OldMaxSize, 1, NewBuffer)
            table.move(OldBuffer, 1, FinalCount - FirstPartLength, FirstPartLength + 1, NewBuffer)
        else
            table.move(OldBuffer, PhysicalStart, PhysicalEnd, 1, NewBuffer)
        end
    end

    self._Buffer = NewBuffer
    self._Count = FinalCount
    self._Head = if FinalCount < NewMaxSize then FinalCount + 1 else 1
    self._MaxSize = NewMaxSize
    self._Tail = 1
end

--[=[
    @method ToArray
    @within RingBuffer
    @return { T }
]=]
function RingBuffer.ToArray<T>(self: RingBuffer<T>): { T }
    local Count = self._Count
    if Count == 0 then return {} end

    local Array = table.create(Count)
    local Head = self._Head
    local MaxSize = self._MaxSize
    local Tail = self._Tail

    if Tail < Head then
        table.move(self._Buffer, Tail, Head - 1, 1, Array)
    else
        local Buffer = self._Buffer
        table.move(Buffer, Tail, MaxSize, 1, Array)
        table.move(Buffer, 1, Head - 1, MaxSize - Tail + 1, Array)
    end

    return Array
end

--[=[
    @method Select
    @within RingBuffer
    @param Start number
    @param End number
    @return { T }
]=]
function RingBuffer.Select<T>(self: RingBuffer<T>, Start: number, End: number): { T }
    if Start > End then return {} end

    local Count = self._Count
    if Count == 0 or Start > Count then return {} end

    if Start < 1 then Start = 1 end
    if End > Count then End = Count end

    local TotalSize = End - Start + 1
    local Result = table.create(TotalSize)

    local MaxSize = self._MaxSize
    local Tail = self._Tail

    local PhysicalStart = Tail + (Start - 1)
    if PhysicalStart > MaxSize then
        PhysicalStart -= MaxSize
    end

    local PhysicalEnd = PhysicalStart + TotalSize - 1
    if PhysicalEnd > MaxSize then
        local Buffer = self._Buffer
        local FirstPartLength = MaxSize - PhysicalStart + 1

        table.move(Buffer, PhysicalStart, MaxSize, 1, Result)
        table.move(Buffer, 1, TotalSize - FirstPartLength, FirstPartLength + 1, Result)
    else
        table.move(self._Buffer, PhysicalStart, PhysicalEnd, 1, Result)
    end

    return Result
end

--[=[
    @method SelectHead
    @within RingBuffer
    @param Start number
    @param End number
    @return { T }
]=]
function RingBuffer.SelectHead<T>(self: RingBuffer<T>, Start: number, End: number): { T }
    if Start > End then return {} end

    local Count = self._Count
    if Count == 0 or Start > Count then return {} end

    if Start < 1 then Start = 1 end
    if End > Count then End = Count end

    local ActualStart = Count - End + 1
    local ActualEnd = Count - Start + 1

    local TotalSize = ActualEnd - ActualStart + 1
    local Result = table.create(TotalSize)

    local MaxSize = self._MaxSize
    local Tail = self._Tail

    local PhysicalStart = Tail + (ActualStart - 1)
    if PhysicalStart > MaxSize then
        PhysicalStart -= MaxSize
    end

    local PhysicalEnd = PhysicalStart + TotalSize - 1
    if PhysicalEnd > MaxSize then
        local Buffer = self._Buffer
        local FirstPartLength = MaxSize - PhysicalStart + 1

        table.move(Buffer, PhysicalStart, MaxSize, 1, Result)
        table.move(Buffer, 1, TotalSize - FirstPartLength, FirstPartLength + 1, Result)
    else
        table.move(self._Buffer, PhysicalStart, PhysicalEnd, 1, Result)
    end

    return Result
end

--[=[
    @method ForEachUnsafe
    @within RingBuffer
    @param Callback (number, T) -> ()
    :::warning
    Changing the RingBuffer state while iterating over it will result 
    unexpected behavior.
    Once your function is doing that, please use `ToArray`.
    :::
]=]
function RingBuffer.ForEachUnsafe<T>(self: RingBuffer<T>, Callback: (number, T) -> ())
    local Buffer = self._Buffer
    local Cursor = self._Tail
    local MaxSize = self._MaxSize

    for Index = 1, self._Count do
        Callback(Index, Buffer[Cursor] :: T)
        Cursor += 1
        if Cursor > MaxSize then Cursor = 1 end
    end
end

local function Iterator<T>(self: RingBuffer<T>, Index: number): (number, T)
    local Count = self._Count
    if Index < Count then
        local Cursor = self._Tail + Index
        local MaxSize = self._MaxSize

        if Cursor > MaxSize then return Index + 1, self._Buffer[Cursor - MaxSize] end
        return Index + 1, self._Buffer[Cursor]
    end

    return nil :: any, nil :: any
end

--[=[
    @method IterateUnsafe
    @within RingBuffer
    @return (RingBuffer<T>, number) -> (number, T)
    @return RingBuffer<T>
    @return number
    :::warning
    Changing the RingBuffer state while iterating over it will result 
    unexpected behavior.
    Once your function is doing that, please use `ToArray`.
    :::
]=]
function RingBuffer.IterateUnsafe<T>(
    self: RingBuffer<T>
): ((RingBuffer<T>, number) -> (number, T), RingBuffer<T>, number)
    return Iterator, self, 0
end

--[=[
    @method Clear
    @within RingBuffer
]=]
function RingBuffer.Clear<T>(self: RingBuffer<T>)
    table.clear(self._Buffer)

    self._Count = 0
    self._Head = 1
    self._Tail = 1
end

--[=[
    @method Destroy
    @within RingBuffer
    Alias of RingBuffer.Clear
]=]
RingBuffer.Destroy = RingBuffer.Clear

--[=[
    @method GetMaxSize
    @within RingBuffer
    @return number
]=]
function RingBuffer.GetMaxSize<T>(self: RingBuffer<T>) return self._MaxSize end

--[=[
    @method GetCount
    @within RingBuffer
    @return number
]=]
function RingBuffer.GetCount<T>(self: RingBuffer<T>) return self._Count end

--[=[
    @method IsEmpty
    @within RingBuffer
    @return boolean
]=]
function RingBuffer.IsEmpty<T>(self: RingBuffer<T>) return self._Count == 0 end

--[=[
    @method IsFull
    @within RingBuffer
    @return boolean
]=]
function RingBuffer.IsFull<T>(self: RingBuffer<T>) return self._Count == self._MaxSize end

return RingBuffer
